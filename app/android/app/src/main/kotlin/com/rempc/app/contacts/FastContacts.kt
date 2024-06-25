package com.rempc.app.contacts

import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.provider.ContactsContract
import android.provider.ContactsContract.CommonDataKinds.Phone
import android.provider.ContactsContract.CommonDataKinds.Email
import android.provider.ContactsContract.CommonDataKinds.Organization
import android.provider.ContactsContract.CommonDataKinds.StructuredName
import android.util.Log
import androidx.core.content.ContentResolverCompat
import androidx.lifecycle.*
import androidx.work.ListenableWorker
import com.google.gson.Gson
import com.rempc.app.api.ApiClient
import com.rempc.app.models.ContactsBody
import com.rempc.app.retrieveJson
import com.rempc.app.storeJson
import kotlinx.coroutines.runBlocking
import java.util.concurrent.*

enum class ContactField {
    // Name-related
    DISPLAY_NAME,
    NAME_PREFIX,
    GIVEN_NAME,
    MIDDLE_NAME,
    FAMILY_NAME,
    NAME_SUFFIX,

    // Organization-related
    COMPANY,
    DEPARTMENT,
    JOB_DESCRIPTION,

    // Phone-related
    PHONE_NUMBERS,
    PHONE_LABELS,

    // Email-related
    EMAIL_ADDRESSES,
    EMAIL_LABELS;

    fun toProjectionStrings(): Set<String> = when (this) {
        DISPLAY_NAME -> setOf(StructuredName.DISPLAY_NAME)
        NAME_PREFIX -> setOf(StructuredName.PREFIX)
        GIVEN_NAME -> setOf(StructuredName.GIVEN_NAME)
        MIDDLE_NAME -> setOf(StructuredName.MIDDLE_NAME)
        FAMILY_NAME -> setOf(StructuredName.FAMILY_NAME)
        NAME_SUFFIX -> setOf(StructuredName.SUFFIX)
        COMPANY -> setOf(Organization.COMPANY)
        DEPARTMENT -> setOf(Organization.DEPARTMENT)
        JOB_DESCRIPTION -> setOf(Organization.TITLE)
        PHONE_NUMBERS -> setOf(Phone.NUMBER)
        PHONE_LABELS -> setOf(Phone.TYPE, Phone.LABEL)
        EMAIL_ADDRESSES -> setOf(Email.ADDRESS)
        EMAIL_LABELS -> setOf(Email.TYPE, Email.LABEL)
    }

    companion object {
        fun fromString(str: String) = when (str) {
            "displayName" -> DISPLAY_NAME
            "namePrefix" -> NAME_PREFIX
            "givenName" -> GIVEN_NAME
            "middleName" -> MIDDLE_NAME
            "familyName" -> FAMILY_NAME
            "nameSuffix" -> NAME_SUFFIX
            "company" -> COMPANY
            "department" -> DEPARTMENT
            "jobDescription" -> JOB_DESCRIPTION
            "phoneNumbers" -> PHONE_NUMBERS
            "phoneLabels" -> PHONE_LABELS
            "emailAddresses" -> EMAIL_ADDRESSES
            "emailLabels" -> EMAIL_LABELS
            else -> throw IllegalArgumentException("Unknown field: $str")
        }
    }
}

private enum class ContactPart {
    PHONES, EMAILS, STRUCTURED_NAME, ORGANIZATION;

    val contentUri: Uri
        get() = when (this) {
            PHONES -> Phone.CONTENT_URI
            EMAILS -> Email.CONTENT_URI
            STRUCTURED_NAME -> ContactsContract.Data.CONTENT_URI
            ORGANIZATION -> ContactsContract.Data.CONTENT_URI
        }
    val contactIdColumn: String
        get() = when (this) {
            PHONES -> Phone.CONTACT_ID
            EMAILS -> Email.CONTACT_ID
            STRUCTURED_NAME -> StructuredName.CONTACT_ID
            ORGANIZATION -> Organization.CONTACT_ID
        }
    val selection: String
        get() = when (this) {
            PHONES -> "${Phone.MIMETYPE} = ?"
            EMAILS -> "${Email.MIMETYPE} = ?"
            STRUCTURED_NAME -> "${StructuredName.MIMETYPE} = ?"
            ORGANIZATION -> "${Organization.MIMETYPE} = ?"
        }
    val selectionArgs: Array<String>
        get() = when (this) {
            PHONES -> arrayOf(Phone.CONTENT_ITEM_TYPE)
            EMAILS -> arrayOf(Email.CONTENT_ITEM_TYPE)
            STRUCTURED_NAME -> arrayOf(StructuredName.CONTENT_ITEM_TYPE)
            ORGANIZATION -> arrayOf(Organization.CONTENT_ITEM_TYPE)
        }
    val sortOrder: String
        get() = when (this) {
            PHONES -> "${Phone.CONTACT_ID} ASC"
            EMAILS -> "${Email.CONTACT_ID} ASC"
            STRUCTURED_NAME -> "${StructuredName.CONTACT_ID} ASC"
            ORGANIZATION -> "${Organization.CONTACT_ID} ASC"
        }

    companion object {
        fun fromFields(fields: Set<ContactField>): Set<ContactPart> {
            return fields.map { field ->
                when (field) {
                    ContactField.DISPLAY_NAME,
                    ContactField.NAME_PREFIX,
                    ContactField.GIVEN_NAME,
                    ContactField.MIDDLE_NAME,
                    ContactField.FAMILY_NAME,
                    ContactField.NAME_SUFFIX -> STRUCTURED_NAME

                    ContactField.COMPANY,
                    ContactField.DEPARTMENT,
                    ContactField.JOB_DESCRIPTION -> ORGANIZATION

                    ContactField.PHONE_NUMBERS,
                    ContactField.PHONE_LABELS -> PHONES

                    ContactField.EMAIL_ADDRESSES,
                    ContactField.EMAIL_LABELS -> EMAILS
                }
            }.toSet()
        }
    }
}

/** FastContactsPlugin */
class FastContactsPlugin(context: Context) : LifecycleOwner, ViewModelStoreOwner {
    private val contentResolver: ContentResolver = context.contentResolver
    private val apiClient = ApiClient.getInstance().create(ApiClient::class.java)

    private val allContactsExecutor = Executors.newSingleThreadExecutor()
    private val allContactsPartExecutors =
        ContactPart.values().associateWith { Executors.newSingleThreadExecutor() }

    private var allContacts: List<Contact> = emptyList()
    private var selectedFields: Set<ContactField> = emptySet()

    fun fetchAllContacts(
        context: Context,
        fieldsQuery: List<ContactField>,
        deviceId: String?,
        authToken: String
    ) {
        val fields = fieldsQuery.toSet()
        val contactParts = ContactPart.fromFields(fields)

        selectedFields = fields

        val partialContacts = ConcurrentHashMap<ContactPart, Collection<Contact>>()
        val fetchCompletionLatch = CountDownLatch(contactParts.size)


        contactParts.map { part ->
            allContactsPartExecutors[part]!!.execute {
                try {
                    val contacts = fetchPartialContacts(part, fields)
                    partialContacts[part] = contacts
                } finally {
                    fetchCompletionLatch.countDown()
                }
            }
        }

        allContactsExecutor.execute {
            fetchCompletionLatch.await()
            val partialContactsLatch = CountDownLatch(partialContacts.values.size)
            val mergedContacts = mutableMapOf<String, Contact>()
            for (part in partialContacts.values.flatten()) {
                val existing = mergedContacts[part.id]
                if (existing == null) {
                    mergedContacts[part.id] = part
                } else {
                    existing.mergeWith(part)
                }
                partialContactsLatch.countDown();
            }
            allContacts = mergedContacts.values.toList()
            partialContactsLatch.await()
            try {
                runBlocking {
                    val contacts = allContacts
                        .filter { it.phones.isNotEmpty() }
                        .map {
                            mapOf(
                                "displayName" to it.structuredName?.displayName,
                                "phones" to it.phones.map { it.number }.toList()
                            )
                        }.toList()
                    val oldContacts = retrieveJson(
                        context,
                        "stored_contacts",
                        List::class.java
                    ) as? List<Map<String, Any?>>
                    val data = if (oldContacts?.isNotEmpty() == true) {
                        val difference1 = findDifference(contacts, oldContacts)
                        val difference2 = findDifference(oldContacts, contacts)
                        val allDifference = difference1 + difference2
                        allDifference
                    } else {
                        contacts
                    }

                    storeJson(context, "stored_contacts", contacts)

                    if (data.size > 50) {
                        val chunked = data.chunked(50)
                        for (chunk in chunked) {
                            apiClient.contactsSync(
                                token = authToken,
                                deviceId = deviceId,
                                contactsBody = ContactsBody(
                                    contacts = Gson().toJson(chunk),
                                    deviceId = deviceId,
                                    from_scheduler = "1"
                                )
                            ).execute()
                        }
                    } else if (data.isNotEmpty()) {
                        apiClient.contactsSync(
                            token = authToken,
                            deviceId = deviceId,
                            contactsBody = ContactsBody(
                                contacts = Gson().toJson(data),
                                deviceId = deviceId,
                                from_scheduler = "1"
                            )
                        ).execute()
                    }
                    clearFetchedContacts()
                    ListenableWorker.Result.success()
                }
            } catch (e: Exception) {
                clearFetchedContacts()
                ListenableWorker.Result.failure()
            }
        }
    }

    fun getAllContacts(): List<Contact> {
        return allContacts
    }

    fun clearFetchedContacts() {
        allContacts = emptyList()
        selectedFields = emptySet()
    }

    fun getContactImage(id: String, size: String): ByteArray? {
        val contactId = id.toLong()
        return if (size == "thumbnail") {
            getContactThumbnail(contactId)
        } else {
            getContactImage(contactId)
        }
    }

//    fun getLifecycle(): Lifecycle {
//        val registry = LifecycleRegistry(this)
//        registry.currentState = Lifecycle.State.RESUMED
//        return registry
//    }
//
//    fun getViewModelStore(): ViewModelStore {
//        return ViewModelStore()
//    }

    private lateinit var _lifecycle: Lifecycle
    override val lifecycle: Lifecycle
        get() = _lifecycle

    private lateinit var _viewModelStore: ViewModelStore
    override val viewModelStore: ViewModelStore
        get() = _viewModelStore

    private fun fetchPartialContacts(
        part: ContactPart,
        fields: Set<ContactField>
    ): Collection<Contact> {
        return when (part) {
            ContactPart.PHONES -> readPhonesInfo(fields)
            ContactPart.EMAILS -> readEmailsInfo(fields)
            ContactPart.STRUCTURED_NAME -> readStructuredNameInfo(fields)
            ContactPart.ORGANIZATION -> readOrganizationInfo(fields)
        }.values
    }

    private fun readStructuredNameInfo(fields: Set<ContactField>): Map<Long, Contact> {
        val contacts = mutableMapOf<Long, Contact>()
        readTargetInfo(ContactPart.STRUCTURED_NAME, fields) { cursor ->
            val contactId = cursor.getLong(StructuredName.CONTACT_ID)!!
            contacts[contactId] = Contact(
                id = contactId.toString(),
                structuredName = StructuredName(
                    displayName = cursor.getString(StructuredName.DISPLAY_NAME) ?: "",
                    namePrefix = cursor.getString(StructuredName.PREFIX) ?: "",
                    givenName = cursor.getString(StructuredName.GIVEN_NAME) ?: "",
                    middleName = cursor.getString(StructuredName.MIDDLE_NAME) ?: "",
                    familyName = cursor.getString(StructuredName.FAMILY_NAME) ?: "",
                    nameSuffix = cursor.getString(StructuredName.SUFFIX) ?: "",
                ),
            )
        }
        return contacts
    }

    private fun readPhonesInfo(fields: Set<ContactField>): Map<Long, Contact> {
        val contacts = mutableMapOf<Long, Contact>()
        readTargetInfo(ContactPart.PHONES, fields) { cursor ->
            val contactId = cursor.getLong(Phone.CONTACT_ID)!!
            val contactPhone = ContactPhone(
                number = cursor.getString(Phone.NUMBER) ?: "",
                label = cursor.getString(Phone.LABEL)
                    ?: cursor.getInt(Phone.TYPE)?.let(::getPhoneLabel)
                    ?: "",
            )

            if (contacts.containsKey(contactId)) {
                (contacts[contactId]!!.phones as MutableList<ContactPhone>).add(contactPhone)
            } else {
                contacts[contactId] = Contact(
                    id = contactId.toString(),
                    phones = mutableListOf(contactPhone),
                )
            }
        }
        return contacts
    }

    private fun getPhoneLabel(type: Int): String {
        return when (type) {
            Phone.TYPE_ASSISTANT -> "assistant"
            Phone.TYPE_CALLBACK -> "callback"
            Phone.TYPE_CAR -> "car"
            Phone.TYPE_COMPANY_MAIN -> "companyMain"
            Phone.TYPE_FAX_HOME -> "faxHome"
            Phone.TYPE_FAX_WORK -> "faxWork"
            Phone.TYPE_HOME -> "home"
            Phone.TYPE_ISDN -> "isdn"
            Phone.TYPE_MAIN -> "main"
            Phone.TYPE_MMS -> "mms"
            Phone.TYPE_MOBILE -> "mobile"
            Phone.TYPE_OTHER -> "other"
            Phone.TYPE_OTHER_FAX -> "faxOther"
            Phone.TYPE_PAGER -> "pager"
            Phone.TYPE_RADIO -> "radio"
            Phone.TYPE_TELEX -> "telex"
            Phone.TYPE_TTY_TDD -> "ttyTtd"
            Phone.TYPE_WORK -> "work"
            Phone.TYPE_WORK_MOBILE -> "workMobile"
            Phone.TYPE_WORK_PAGER -> "workPager"
            Phone.TYPE_CUSTOM -> "custom"
            else -> ""
        }
    }

    private fun readEmailsInfo(fields: Set<ContactField>): Map<Long, Contact> {
        val contacts = mutableMapOf<Long, Contact>()
        readTargetInfo(ContactPart.EMAILS, fields) { cursor ->
            val contactId = cursor.getLong(Email.CONTACT_ID)!!
            val contactEmail = ContactEmail(
                address = cursor.getString(Email.ADDRESS) ?: "",
                label = cursor.getString(Email.LABEL)
                    ?: cursor.getInt(Email.TYPE)?.let(::getEmailAddressLabel)
                    ?: "",
            )

            if (contacts.containsKey(contactId)) {
                (contacts[contactId]!!.emails as MutableList<ContactEmail>).add(contactEmail)
            } else {
                contacts[contactId] = Contact(
                    id = contactId.toString(),
                    emails = mutableListOf(contactEmail),
                )
            }
        }
        return contacts
    }

    private fun getEmailAddressLabel(type: Int): String {
        return when (type) {
            Email.TYPE_HOME -> "home"
            Email.TYPE_OTHER -> "other"
            Email.TYPE_WORK -> "work"
            Email.TYPE_CUSTOM -> "custom"
            else -> ""
        }
    }

    private fun readOrganizationInfo(fields: Set<ContactField>): Map<Long, Contact> {
        val contacts = mutableMapOf<Long, Contact>()
        readTargetInfo(ContactPart.ORGANIZATION, fields) { cursor ->
            val contactId = cursor.getLong(Organization.CONTACT_ID)!!
            contacts[contactId] = Contact(
                id = contactId.toString(),
                organization = Organization(
                    company = cursor.getString(Organization.COMPANY) ?: "",
                    department = cursor.getString(Organization.DEPARTMENT) ?: "",
                    jobDescription = cursor.getString(Organization.JOB_DESCRIPTION) ?: "",
                )
            )
        }
        return contacts
    }

    private fun readTargetInfo(
        contactPart: ContactPart,
        fields: Set<ContactField>,
        onData: (cursor: Cursor) -> Unit
    ) {
        val fieldNames = fields.map { it.toProjectionStrings() }.flatten().toMutableList()
        fieldNames.add(0, contactPart.contactIdColumn)
        val projection = fieldNames.toTypedArray()

        val cursor = ContentResolverCompat.query(
            contentResolver,
            contactPart.contentUri,
            projection,
            contactPart.selection,
            contactPart.selectionArgs,
            contactPart.sortOrder,
            null,
        )
        cursor?.use {
            while (!cursor.isClosed && cursor.moveToNext()) {
                onData(cursor)
            }
        }
    }

    private fun getContactThumbnail(contactId: Long): ByteArray? {
        val contactUri =
            ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, contactId)
        return contentResolver.query(
            Uri.withAppendedPath(contactUri, ContactsContract.Contacts.Photo.CONTENT_DIRECTORY),
            arrayOf(ContactsContract.Contacts.Photo.PHOTO),
            null,
            null,
            null,
        )?.use { cursor ->
            if (cursor.moveToNext()) cursor.getBlob(0) else null
        }
    }

    private fun getContactImage(contactId: Long): ByteArray? {
        val contactUri =
            ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, contactId)
        val displayPhotoUri =
            Uri.withAppendedPath(contactUri, ContactsContract.Contacts.Photo.DISPLAY_PHOTO)

        return contentResolver.openAssetFileDescriptor(displayPhotoUri, "r")?.use { fd ->
            fd.createInputStream().use {
                it.readBytes()
            }
        }
    }
}

fun Cursor.getString(col: String): String? {
    val index = getColumnIndex(col)
    if (index < 0) {
        return null
    }
    return getString(index)
}

fun Cursor.getInt(col: String): Int? {
    val index = getColumnIndex(col)
    if (index < 0) {
        return null
    }
    return getInt(index)
}

fun Cursor.getLong(col: String): Long? {
    val index = getColumnIndex(col)
    if (index < 0) {
        return null
    }
    return getLong(index)
}

fun findDifference(
    list1: List<Map<String, Any?>>,
    list2: List<Map<String, Any?>>
): List<Map<String, Any?>> {
    // Filter the maps in the first list
    return list1.filter { map1 ->
        // Check if there is a map in the second list that equals to the current map
        list2.none { map2 ->
            map1 == map2
        }
    }
}
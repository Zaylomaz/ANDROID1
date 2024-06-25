package com.rempc.app.models

import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName

class PhoneInfo {
    @SerializedName("names")
    @Expose
    private var names: List<String?>? = null

    @SerializedName("cities")
    @Expose
    private var cities: List<String?>? = null

    @SerializedName("addresses")
    @Expose
    private var addresses: List<Any?>? = null

    @SerializedName("orders")
    @Expose
    private var orders: List<Any?>? = null

    fun getNames(): List<String?>? {
        return names
    }

    fun setNames(names: List<String?>?) {
        this.names = names
    }

    fun getCities(): List<String?>? {
        return cities
    }

    fun setCities(cities: List<String?>?) {
        this.cities = cities
    }

    fun getAddresses(): List<Any?>? {
        return addresses
    }

    fun setAddresses(addresses: List<Any?>?) {
        this.addresses = addresses
    }

    fun getOrders(): List<Any?>? {
        return orders
    }

    fun setOrders(orders: List<Any?>?) {
        this.orders = orders
    }
}

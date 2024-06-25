package ua.bank2.back_blocker

import io.flutter.embedding.android.FlutterFragmentActivity

open class BackBlockerActivity : FlutterFragmentActivity() {
    override fun onBackPressed() {
        if (BackBlocker.canGoBack) {
            super.onBackPressed()
        }
    }
}
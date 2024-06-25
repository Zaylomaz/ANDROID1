package com.rempc.app;

import android.Manifest;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.location.LocationRequest;
import android.os.Build;
import android.os.Bundle;
import android.os.CancellationSignal;
import android.os.IBinder;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;

import com.apparence.camerawesome_example.MainActivity;
import com.rempc.app.eventBus.commands.GetCurrentGPSLocationCommand;
import com.rempc.app.eventBus.commands.NewLocationCommand;

import org.greenrobot.eventbus.EventBus;

import java.util.function.Consumer;

public class LocationTrack extends Service implements LocationListener {

    private final Context mContext;

    boolean checkGPS = false;

    boolean checkNetwork = false;

    boolean canGetGPSLocation = false;
    boolean canGetNetworkLocation = false;

    Location loc;
    double latitude;
    double longitude;

    private static final long MIN_DISTANCE_CHANGE_FOR_UPDATES = 90;

    private static final long MIN_TIME_BW_UPDATES = 1000 * 60 * 2;

    protected LocationManager locationManager;

    public LocationTrack(Context mContext) {
        this.mContext = mContext;
        getLocation();
    }

    private Location getLocation() {

        try {
            locationManager = (LocationManager) mContext
                    .getSystemService(LOCATION_SERVICE);

            // get GPS status
            checkGPS = locationManager
                    .isProviderEnabled(LocationManager.GPS_PROVIDER);

            // get network provider status
            checkNetwork = locationManager
                    .isProviderEnabled(LocationManager.NETWORK_PROVIDER);

            if (!checkGPS && !checkNetwork) {
                Toast.makeText(mContext, "No data from GPS sensor", Toast.LENGTH_SHORT).show();
            } else {
                if (checkGPS) {
                    this.canGetGPSLocation = true;
                }
                if (checkNetwork) {
                    this.canGetNetworkLocation = true;
                }
                // if GPS Enabled get lat/long using GPS Services
//                if (checkGPS) {
//
//                    if (ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
//                        // TODO: Consider calling
//                        //    ActivityCompat#requestPermissions
//                        // here to request the missing permissions, and then overriding
//                        //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
//                        //                                          int[] grantResults)
//                        // to handle the case where the user grants the permission. See the documentation
//                        // for ActivityCompat#requestPermissions for more details.
//                    }
//                    locationManager.requestLocationUpdates(
//                            LocationManager.GPS_PROVIDER,
//                            MIN_TIME_BW_UPDATES,
//                            MIN_DISTANCE_CHANGE_FOR_UPDATES, this);
//                    loc = locationManager
//                            .getLastKnownLocation(LocationManager.GPS_PROVIDER);
//                    if (loc != null) {
//                        latitude = loc.getLatitude();
//                        longitude = loc.getLongitude();
//                    }
//                    EventBus.getDefault().post(new GetCurrentGPSLocationCommand(latitude, longitude, getIsFake(), LocationManager.GPS_PROVIDER));
//                }


                if (checkNetwork) {


                    if (ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                        // TODO: Consider calling
                        //    ActivityCompat#requestPermissions
                        // here to request the missing permissions, and then overriding
                        //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                        //                                          int[] grantResults)
                        // to handle the case where the user grants the permission. See the documentation
                        // for ActivityCompat#requestPermissions for more details.
                    }
                    locationManager.requestLocationUpdates(
                            LocationManager.NETWORK_PROVIDER,
                            MIN_TIME_BW_UPDATES,
                            MIN_DISTANCE_CHANGE_FOR_UPDATES, this);

                    if (locationManager != null) {
                        loc = locationManager
                                .getLastKnownLocation(LocationManager.NETWORK_PROVIDER);

                    }

                    if (loc != null) {
                        latitude = loc.getLatitude();
                        longitude = loc.getLongitude();
                    }
                    EventBus.getDefault().post(new GetCurrentGPSLocationCommand(latitude, longitude, getIsFake(), LocationManager.NETWORK_PROVIDER));
                }

            }


        } catch (Exception e) {
            e.printStackTrace();
        }

        return loc;
    }

    @Nullable
    public Location getLastKnownGPSLocation() {
        if (ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return null;
        }
        return locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
    }

    @Nullable
    public Location getLastKnownNetworkLocation() {
        if (ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return null;
        }
        return locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
    }

    public double getLongitude() {
        if (loc != null) {
            longitude = loc.getLongitude();
        }
        return longitude;
    }

    public double getLatitude() {
        if (loc != null) {
            latitude = loc.getLatitude();
        }
        return latitude;
    }

    public boolean getIsFake() {
        if (loc != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                return loc.isMock();
            } else {
                return loc.isFromMockProvider();
            }
        }
        return false;
    }

    public boolean canGetGPSLocation() {
        return this.canGetGPSLocation;
    }

    public boolean canGetNetworkLocation() {
        return this.canGetNetworkLocation;
    }

    public void stopListener() {
        if (locationManager != null) {

            if (ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                // TODO: Consider calling
                //    ActivityCompat#requestPermissions
                // here to request the missing permissions, and then overriding
                //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                //                                          int[] grantResults)
                // to handle the case where the user grants the permission. See the documentation
                // for ActivityCompat#requestPermissions for more details.
                return;
            }
            locationManager.removeUpdates(LocationTrack.this);
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onLocationChanged(@NonNull Location location) {
        this.loc = location;
        if (BuildConfig.FLAVOR == "dev") {
            String message = location.getProvider() + " => " + location.getLatitude() + "/" + location.getLongitude();
            Toast.makeText(mContext, message, Toast.LENGTH_SHORT).show();
        }
        EventBus.getDefault().post(new NewLocationCommand(getLatitude(), getLongitude(), getIsFake(), location.getProvider()));
    }

    @Override
    public void onProviderEnabled(@NonNull String s) {
        if (s.equals(LocationManager.GPS_PROVIDER)) {
            this.canGetGPSLocation = true;
        }
        if (s.equals(LocationManager.NETWORK_PROVIDER)) {
            this.canGetNetworkLocation = true;
        }
    }

    @Override
    public void onProviderDisabled(@NonNull String s) {
        if (s.equals(LocationManager.GPS_PROVIDER)) {
            this.canGetGPSLocation = false;
        }
        if (s.equals(LocationManager.NETWORK_PROVIDER)) {
            this.canGetNetworkLocation = false;
        }
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {
    }
}

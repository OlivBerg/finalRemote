WITH AggregatedData AS (
    SELECT
        IoTHub.ConnectionDeviceId AS DeviceId,
        IoTHub.ConnectionDeviceId AS location,
        AVG(iceThickness) AS AvgIceThickness,
        MIN(iceThickness) AS MinIceThickness,
        MAX(iceThickness) AS MaxIceThickness,
        
        AVG(surfaceTemp) AS AvgSurfaceTemp,
        MIN(surfaceTemp) AS MinSurfaceTemp,
        MAX(surfaceTemp) AS MaxSurfaceTemp,
        
        MAX(snowAccumulation) AS MaxSnowAccumulation,
        
        AVG(externalTemp) AS AvgExternalTemp,
        
        COUNT(*) AS ReadingCount,
        
        CASE
            WHEN AVG(iceThickness) >= 30 AND AVG(surfaceTemp) <= -2 THEN 'Safe'
            WHEN AVG(iceThickness) >= 25 AND AVG(surfaceTemp) <= 0 THEN 'Caution'
            ELSE 'Unsafe'
        END AS SafetyStatus,
        
        System.Timestamp AS WindowEndTime
    FROM
        [finalRemoteHub]
    GROUP BY
        IoTHub.ConnectionDeviceId,
        TumblingWindow(minute, 1)
)

SELECT * INTO [archive] FROM AggregatedData;

SELECT * INTO [SensorAggregations] FROM AggregatedData;
# Final Project - Remote Data and RT Application

This project is simulates a mainly cloud-native stack that incorporate IoT Hub, Stream Analytics, Blob Storage, CosmoDB and App Services. The goal is to process telemetry data of IoT devices uses to track weather Rideau Canal safety metrics and display them to a web page.

## Student Information

Student: Olivie Bergeron

Student ID: 041068227

## System Architecture

![architecture](architecture/image.png)

This architecture starts by sending simulated data from the Sensor Simulator. The data is returned as JSON and linked to a connection string for the respective simulated device. It is then sent to Azure Stream Analytics for processing, which returns averages of certain values and a calculated safety response. The processed data is output to two endpoints: Cosmos DB (for display) and Azure Blob Storage (for archiving). The Node/Express.js server retrieves display data from Cosmos DB for the web dashboard, refreshing every 30 seconds.

## Implementation Overview

### [IoT Sensor Simulation](https://github.com/OlivBerg/SensorSimRemote)

The simulator mimics physical sensors, sending artificial telemetry data for "NAC", "Dow Lake", and "Fifth Avenue" locations to Azure IoT Hub via MQTT. This is useful for testing data pipelines for the Rideau Canal Monitoring Dashboard.

### Stream Analytics job (include query)

This query create a callable expression that is used to output the processed data to two output :

1. BlobStorage --> archive
2. CosmoDB --> SensorAggregations

```
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
        TumblingWindow(minute, 5)
)

SELECT * INTO [archive] FROM AggregatedData;

SELECT * INTO [SensorAggregations] FROM AggregatedData;
```

### Cosmos DB setup

1. Create a Cosmos DB
2. create a DB
3. Connect Cosmos DB to Stream Analytics job as an output source

### Blob Storage configuration

1. Create a storage account
2. create a container
3. Connect storage to Stream Analytics job as an output source

### [Web Dashboard](https://github.com/OlivBerg/25F_CST8916_Final_Project_Web-Dashboard)

A lightweight web dashboard that visualizes real-time telemetry, safety indicators, and historical metrics.

### Azure App Service deployment

1. Create a `Web App` throught `App Services`
2. In the `Deployment` tab, enable `Continuous deployment` and provide the github repo info
3. Review and Create
4. Create the 5 enviroment variable : `COSMOS_ENDPOINT`, `COSMOS_KEY`, `COSMOS_DATABASE`, `COSMOS_CONTAINER` and `PORT`
5. Wait until the app updates or manually trigger an update in your repo so that Github Actions incorporates those value

## Repository Links

### 1. Main Documentation Repository

- **URL:** https://github.com/OlivBerg/finalRemote
- **Description:** Complete project documentation, architecture, screenshots, and guides

### 2. Sensor Simulation Repository

- **URL:** https://github.com/OlivBerg/SensorSimRemote
- **Description:** IoT sensor simulator code

### 3. Web Dashboard Repository

- **URL:** https://github.com/OlivBerg/25F_CST8916_Final_Project_Web-Dashboard
- **Description:** Web dashboard application

## Video Demonstration

[YouTube](https://youtu.be/ENaMSjghwiM)

## Results and Analysis

    Sample outputs and screenshots
    Data analysis
    System performance observations

## Challenges and Solutions

Document ID for the output to CosmoDB always resulted to a error related to invalid ID. Inputing no value to the Document ID slot made the output work.

## AI Tools Disclosure (if used)

- Used AI to refactor the CSS and HTML of the webpage
- Used AI to help formulate my documentation

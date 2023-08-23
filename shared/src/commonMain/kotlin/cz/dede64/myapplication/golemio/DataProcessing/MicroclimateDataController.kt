package cz.dede64.myapplication.golemio.DataProcessing

import cz.dede64.myapplication.golemio.DataFetching.GolemioAPIController
import cz.dede64.myapplication.golemio.DataFetching.MicroclimateMeasuredValue
import cz.dede64.myapplication.golemio.DataFetching.MicroclimateMeasurement
import cz.dede64.myapplication.golemio.DataFetching.MicroclimatePoint

class MicroclimateDataController {
    /**
     * This controller is used for processing received data from Golemio API.
     */

    private var microclimateLocations: List<MicroclimatePoint> = emptyList()
    private var measuredValues: ArrayList<MicroclimateMeasuredValue> = ArrayList()

    @Throws(Exception::class)
    suspend fun initializeLocations() {
        /**
         * Fetches all station positions and all measured values, which are available through the API.
         */

        microclimateLocations = GolemioAPIController().fetchClimatePoints()
        populateMeasuredValues()
    }

    private fun populateMeasuredValues() {
        /**
         * Processes fetched stations data and gets a list of all measurable values.
         */

        measuredValues.clear()

        for (location in microclimateLocations) {
            for (measuredValue in location.measuredValues) {
                if (measuredValue !in measuredValues) {
                    measuredValues.add(measuredValue)
                }
            }
        }
    }

    fun getMeasuredValues(): List<MicroclimateMeasuredValue> {
        return measuredValues
    }

    private fun getMicroclimatePoint(pointID: Int): MicroclimatePoint? {
        for (point in microclimateLocations) {
            if (point.pointID == pointID) {
                return point
            }
        }
        return null
    }

    private fun getMicroclimateMeasuredValue(measuredValueString: String): MicroclimateMeasuredValue? {
        for (measuredValue in measuredValues) {
            if (measuredValueString == measuredValue.measure) {
                return measuredValue
            }
        }
        return null
    }

    @Throws(Exception::class)
    suspend fun getDataMeasurements(measuredValue: String, from: String, to: String): List<DataMeasurement> {
        /**
         * Gets measurements for given measurable value and time interval.
         */

        val measuredValueObject: MicroclimateMeasuredValue? = getMicroclimateMeasuredValue(measuredValue)
        var result: ArrayList<DataMeasurement> = ArrayList()

        measuredValueObject ?.let {
            val fetchedData: List<MicroclimateMeasurement> =
                GolemioAPIController().fetchMeasurements(measuredValueObject.measure, fromTimestamp = from, toTimestamp = to)

            for (measurement in fetchedData) {
                val location: MicroclimatePoint? = getMicroclimatePoint(measurement.pointID)
                location?.let {
                    result.add( // TODO add timestamp
                        DataMeasurement(
                            value = measurement.value,
                            measuredValue = measuredValueObject,
                            location = location
                        )
                    )
                }
            }
        }

        return result
    }
}
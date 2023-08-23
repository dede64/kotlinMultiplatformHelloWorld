package cz.dede64.myapplication.golemio.DataProcessing

import cz.dede64.myapplication.golemio.DataFetching.MicroclimateMeasuredValue
import cz.dede64.myapplication.golemio.DataFetching.MicroclimatePoint

class DataMeasurement(
    val value: Float,
    val measuredValue: MicroclimateMeasuredValue,
    val location: MicroclimatePoint
) {

}
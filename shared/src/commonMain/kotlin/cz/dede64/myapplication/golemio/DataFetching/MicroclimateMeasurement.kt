package cz.dede64.myapplication.golemio.DataFetching

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
class MicroclimateMeasurement (

    @SerialName("measured_at")
    val timestamp: String,

    @SerialName("point_id")
    val pointID: Int,

    @SerialName("location_id")
    val locationID: Int,

    @SerialName("measure")
    val measure: String,

    @SerialName("value")
    val value: Float,

    @SerialName("unit")
    val unit: String
)

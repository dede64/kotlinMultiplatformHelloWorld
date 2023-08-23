package cz.dede64.myapplication.golemio.DataFetching

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class MicroclimatePoint (

    @SerialName("lat")
    val latitude: Float,

    @SerialName("lng")
    val longitude: Float,

    @SerialName("point_id")
    val pointID: Int,

    @SerialName("location_id")
    val locationID: Int,

    @SerialName("measures")
    val measuredValues: List<MicroclimateMeasuredValue>,

    @SerialName("location")
    val title: String
)

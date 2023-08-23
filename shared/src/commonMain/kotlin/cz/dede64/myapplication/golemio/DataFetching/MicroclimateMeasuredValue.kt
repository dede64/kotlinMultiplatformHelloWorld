package cz.dede64.myapplication.golemio.DataFetching

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class MicroclimateMeasuredValue (

    @SerialName("measure")
    val measure: String,

    @SerialName("measure_cz")
    val title: String,

    @SerialName("unit")
    val unit: String
)

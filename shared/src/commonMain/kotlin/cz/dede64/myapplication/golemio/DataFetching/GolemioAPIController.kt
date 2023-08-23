package cz.dede64.myapplication.golemio.DataFetching

import cz.dede64.myapplication.Platform
import cz.dede64.myapplication.getPlatform
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.get
import io.ktor.client.request.headers
import io.ktor.http.URLProtocol
import io.ktor.http.path
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json

class GolemioAPIController {
    /**
     * This controller is used for calling Golemio API.
     */

    private val platform: Platform = getPlatform()

    private fun getHttpClient(): HttpClient {
        return HttpClient {
            install(ContentNegotiation) {
                json(Json {
                    prettyPrint = true
                    isLenient = true
                    ignoreUnknownKeys = true
                })
            }
            install(HttpTimeout) {
                requestTimeoutMillis = 120000
                socketTimeoutMillis = 120000
                connectTimeoutMillis = 120000
            }
        }
    }

    private fun getApiKey(): String {
        return "Put your key here."
    }

    @Throws(Exception::class)
    suspend fun fetchClimatePoints(): List<MicroclimatePoint> {

        val httpClient = getHttpClient()
        val climatePoints: List<MicroclimatePoint> = httpClient.get {
            url {
                protocol = URLProtocol.HTTPS
                host = "api.golemio.cz"
                path("v2/microclimate/points")
            }
            headers {
                append("X-Access-Token", getApiKey())
            }
        }.body()

        return climatePoints
    }

    @Throws(Exception::class)
    suspend fun fetchMeasurements(measuredValue: String, fromTimestamp: String, toTimestamp: String): List<MicroclimateMeasurement> {
        
        val httpClient = getHttpClient()
        val measurements: List<MicroclimateMeasurement> = httpClient.get {
            url {
                protocol = URLProtocol.HTTPS
                host = "api.golemio.cz"
                path("v2/microclimate/measurements")
                parameters.append("measure", measuredValue)
                parameters.append("from", fromTimestamp)
                parameters.append("to", toTimestamp)
            }
            headers {
                append("X-Access-Token", getApiKey())
            }
        }.body()

        return measurements
    }
}
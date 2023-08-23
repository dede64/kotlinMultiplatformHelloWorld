package cz.dede64.myapplication

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform
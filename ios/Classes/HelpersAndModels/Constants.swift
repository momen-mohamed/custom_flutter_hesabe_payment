import Foundation

// Get these URL from `https://developer.hesabe.com/` -> Environments
// Replace `https://sandbox.hesabe.com` with Test URL or Production URL.

let CHECKOUT_URL = "https://sandbox.hesabe.com/checkout"
let PAYMENT_URL = "https://sandbox.hesabe.com/payment?data="

// Get below values from Merchant Panel, Profile section

let ACCESS_CODE = "2a3789f5-edd1-416d-a472-4357794d6a8c"
let MERCHANT_KEY = "OGzgrmqyDEnlALQRNvzPv8NJ4BwWM019"
let MERCHANT_IV = "DEnlALQRNvzPv8NJ"
let MERCHANT_CODE = "1351719857300"

// This URL are defined by you to get the response from Payment Gateway

let RESPONSE_URL = "http://success.hesbstaging.com"
let FAILURE_URL = "http://failure.hesbstaging.com"
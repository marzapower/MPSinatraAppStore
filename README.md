# MPSinatraAppStore

A Sinatra implementation for a web server that talks with Apple for In-app-purchase-related stuff.

## Installation

Just download the code, then run

``` shell
bundle install
```

from the local folder to install all the required gems.

## Usage

This `sinatra` server works with the `rack` gem. Start the server using:

``` shell
rackup config.ru
```

If you need to do some local test and need to frequently change source files, you can install the `rerun` gem and then
call this:

``` shell
rerun 'rackup'
```

This will automatically relaunch your local server instance whenever a source file is modified.

### Sandbox

To test the calls in sandbox mode, you have to change the `DEBUG` constant at the beginning of `server.rb`. Set this
constant to `true` to sandbox all the calls, or set it to `false` to call the Apple production servers.

## API

The server will support 3 different calls, to:
  1. Verify a purchase receipt with Apple
  2. Locally register a successful purchase
  3. Verify is a product has already been purchased

To accomplish these tasks, the server will require three parameters: a `purchase_receipt`, a `product_identifier` and a `device_id`.

All the exposed API calls can just be reached through the `POST` method.
Each API will respond with a JSON output, with this format:

``` json
{"result": value, "error" : {"message" : error_message}, "data" : custom_data}
```

The `result` parameter will always be returned, with a `0` value for successful calls, and `1` for calls generating errors.

The `error` parameter could be returned when an exception is caught by the server. The inner `message` parameter will
describe the error itself.

The `data` parameter could be returned from API calls that need to send back custom, additional data. Its form is not know a priori.

### Verify receipt

Send `POST` calls to: `http://server/verifyReceipt`
with body:

```
{:purchase_receipt => "myBase64EncodedPurchaseReceipt"}
```

### Register purchase

Send `POST` calls to: `http://server/registerPurchase/:product_identifier/:device_id`

### Verify purchase

Send `POST` calls to: `http://server/verifyPurchase/:product_identifier/:device_id`

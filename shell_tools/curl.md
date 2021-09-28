# cURL

`curl [options] [URL...]`

Multiple URLs simply repeat the process for each URL.
    ftp://example.com/file[1-100].txt
    http://site.{one,two,three}.com

* Download contents of an URL to a file:
  `curl 'http://example.com/file' -o 'filename'`

* Use filename from URL
  `curl -O 'http://example.com/file'`

## Common flags

* `-H, --header` Header
    `curl -H 'content-type: application/json' http://example.com`
    `curl -H 'X-First-Name: Joe' http://example.com`
* `-X, --request` Request
    `-X POST` `-X PUT`. Others: `PUT, DELETE, COPY, MOVE, PROPFIND, etc`
* `-d, --data` Data
    `-d '{"name": "bob"}"`
* `-u, --user <user:password>` User
    `-u lviana:mypass`
* `-T, --upload-file <file>` Upload file
    `curl -T "img[1-100].png" http://www.example.com

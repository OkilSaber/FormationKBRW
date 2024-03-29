var localhost = require('reaxt/config').localhost
var XMLHttpRequest = require("xhr2") // External XmlHTTPReq on browser, xhr2 on server

export const HTTP = new (function () {
    this.get = (url) => this.req('GET', url)
    this.delete = (url) => this.req('DELETE', url)
    this.post = (url, data) => this.req('POST', url, data)
    this.put = (url, data) => this.req('PUT', url, data)

    this.req = (method, url, data) => {
        return new Promise((resolve, reject) => {
            var req = new XMLHttpRequest()
            url = (typeof window !== 'undefined') ? url : localhost + url
            req.open(method, url)
            req.responseType = "text"
            req.setRequestHeader("accept", "application/json,*/*;0.8")
            req.setRequestHeader("content-type", "application/json")
            req.onload = () => {
                if (req.status >= 200 && req.status < 300) {
                    resolve(req.responseText && JSON.parse(req.responseText))
                } else {
                    reject({ http_code: req.status })
                }
            }
            req.onerror = (err) => {
                reject({ http_code: req.status })
            }
            req.send(data && JSON.stringify(data))
        }
        )
    }
})
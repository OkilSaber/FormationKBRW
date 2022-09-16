const ReactDOM = require('react-dom')
const React = require("react")
const Qs = require('qs')
const Cookie = require('cookie')
import { Child } from './orders_list_components';
import { ErrorPage } from './error_page';
import { routes } from './routes'
import { HTTP } from './http'
var browserState = { Child }

export function onPathChange() {
    var path = location.pathname
    var qs = Qs.parse(location.search.slice(1))
    let page = parseInt(qs.page)
    if (isNaN(page) || page < 0)
        qs.page = 0
    var cookies = Cookie.parse(document.cookie)
    browserState = {
        ...browserState,
        path: path,
        qs: qs,
        cookie: cookies
    }
    let routeProps = null
    let route = null
    for (var key in routes) {
        routeProps = routes[key].match(path, qs)
        if (routeProps) {
            route = key
            break;
        }
    }
    browserState = {
        ...browserState,
        ...routeProps,
        route: route
    }
    if (!route)
        return ReactDOM.render(<ErrorPage message={"Not Found"} code={404} />, document.getElementById('root'))
    addRemoteProps(browserState).then(
        (props) => {
            browserState = props
            ReactDOM.render(<Child {...browserState} />, document.getElementById('root'))
        },
        (res) => {
            ReactDOM.render(<ErrorPage message={"Shit happened"} code={res.http_code} />, document.getElementById('root'))
        }
    )
}

export const formatAddress = ({ street: [street], city, postcode }) => `${street}, ${city} ${postcode}`

export const getQuantity = (items) => items.reduce((accumulator, { quantity_to_fetch }) => (accumulator + quantity_to_fetch), 0)

export var goTo = (route, params, query) => {
    var qs = Qs.stringify(query)
    if (parseInt(qs.page) < 0) {
        qs.page = 0
    }
    var url = routes[route].path(params) + ((qs == '') ? '' : ('?' + qs))
    history.pushState({}, "", url)
    onPathChange()
}

function addRemoteProps(props) {
    return new Promise((resolve, reject) => {
        var remoteProps = Array.prototype.concat.apply([],
            props.handlerPath
                .map((c) => c.remoteProps)
                .filter((p) => p)
        )
        remoteProps = remoteProps
            .map((spec_fun) => spec_fun(props))
            .filter((specs) => specs)
            .filter((specs) => !props[specs.prop] || props[specs.prop].url != specs.url)
        if (remoteProps.length == 0)
            return resolve(props)
        const promise_mapper = (spec) => {
            return HTTP.get(spec.url).then((res) => { spec.value = res; return spec })
        }
        const reducer = (acc, spec) => {
            acc[spec.prop] = { url: spec.url, value: spec.value }
            return acc
        }
        const promise_array = remoteProps.map(promise_mapper)
        return Promise.all(promise_array)
            .then(xs => xs.reduce(reducer, props), reject)
            .then((p) => addRemoteProps(p).then(resolve, reject), reject)
    })
}

export const cn = function () {
    var args = arguments, classes = {}
    for (var i in args) {
        var arg = args[i]
        if (!arg) continue
        if ('string' === typeof arg || 'number' === typeof arg) {
            arg.split(" ").filter((c) => c != "").map((c) => {
                classes[c] = true
            })
        } else if ('object' === typeof arg) {
            for (var key in arg) classes[key] = arg[key]
        }
    }
    return Object.keys(classes).map((k) => classes[k] && k || '').join(' ')
}
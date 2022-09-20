var erlastic = require('@kbrw/node_erlastic')
var Bert = require('@kbrw/node_erlastic/bert')
Bert.convention = Bert.ELIXIR

erlastic.server((term, from,current_state, done) => {
    if (term == "hello") return done("reply", "Hello, world!");
    if (term == "what") return done("reply", "What what?");
    if (term[0] == "kbrw") {
        return done(
            "noreply",
            term[1]
        )
    }
    if (term == "kbrw") return done("reply", kbrw);
    throw new Error("unexpected request")
});
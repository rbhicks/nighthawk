# Nighthawk

**N.B.:**

- this project is created as a supervisor application for potential future expansion. As can be seen here, no process is launched and the whole thing exits after running. It’s basically a glorified .exs right now.
- to keep things easy to see, the macro module and the main module are both in the same file.

This is a simple proof of concept implementation of a DSL for creating declarative rules. In this case, three rules are for a theoretical SEO system are defined.

Rule systems of this nature would normally require a separate system to provide the information that the rules act on and a mechanism to fix the rules correctly for all the that information. In this example, these parts are simulated. I.E., the helper functions provide single hard coded values.

To try it out, clone this repo and do the following:

```
cd nighthawk
mix run
```


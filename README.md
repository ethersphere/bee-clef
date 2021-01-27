# What

[*clef*](https://github.com/ethereum/go-ethereum/tree/master/cmd/clef)
is the [Go Ethereum client](https://github.com/ethereum/go-ethereum/)'s
external signer (an external service that signs transactions).

[*bee-clef*](https://github.com/ethersphere/bee-clef) starts up a
custom `clef` instance that is preconfigured to be suitable for
[bee](https://github.com/ethersphere/bee)'s automated operation.

This repo contains the source files for building packages for various
package managers and platforms.

# How

It takes the original `clef` binary and starts it up as a service
with a special configuration that is probably only suitable for `bee`.

`bee` can be configured to use other external signers, but
`bee-clef` is probably not interesting outside the scope of being an
external signer service for `bee`.

# Install

You probably want to follow the
[Swarm Bee manual](https://docs.ethswarm.org/docs/),
or head straight to the
[release download page](https://github.com/ethersphere/bee-clef/releases).

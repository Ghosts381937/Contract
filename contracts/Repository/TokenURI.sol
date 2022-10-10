// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract TokenURI{

    string[][] equipment = [[
        "ipfs://QmRVXDkEDKswoZiznCPrxma6tSaQJr8gR1VsMWqtvfbGWv",
        "ipfs://QmaJdroStCmh3iiGUCffuACW31jNpsRBmpYpza61QjGAfv",
        "ipfs://QmQuuv7ez3CrqJ2V6w7XjuVCQ6cnzQcCWui9FdDDmeq2uv",
        "ipfs://QmUitDKyQmwcdKA2ixHbUzZdNymNP8mRZ51AkDMsd6mnJi",
        "ipfs://QmdQnBdMxgGE3DPcZH9JPT31EThbV4DefkhipyQny12Kuk",
        "ipfs://QmbNebpkj1LBT2XG3htaZ3rHkhL97PFa3H7f4EwwuR5xad",
        "ipfs://QmR74TVPjkaUirrHVAbqa5ExKxwSw1msiea5GP3mKPZWVt",
        "ipfs://QmdCLrDu2CVaYszTjMNrRx8QGgWc6Kw5pMcpdSoTTZvg7N"
        ],[
        "ipfs://Qma3HtztpwqKCjn6cvJkv5LcuH6mKzQJCaSfHvyKy8WmMT",
        "ipfs://QmWEdHQYCYUyf9vJ3QvyZXHTGBT4Bo2W8t14oe84ayCGR2",
        "ipfs://QmQ5Z57VQJKF9TMtf7CDHC16zVbJV2sWRngXwkoDgkUww8",
        "ipfs://QmfYctBhh6wfrh13gxNH7C5edzwXouHmMkfiUE9d5SKjjC",
        "ipfs://QmQUWqE2YpWoMWY5qg9V3T4v7jRdmsEGmJgHUTx6dcQqYT",
        "ipfs://QmXqWKxXQ6DE73yLe8Uss4xPVHVcdFnGjfuMVMgevAxnHT",
        "ipfs://QmZitiKHkXoA5UmERwXQPRwcLHbWu1ivimaarNJFsGLFbJ",
        "ipfs://QmcPU8aKCR347LTbbJQ3vj1H5kzhee6gQ2xorEcQoRfoWx"
        ],[
        "ipfs://QmbU4DhKYadBvVqMLjhTeaPcWvCFBgeh5uskpeZo8J8MYU",
        "ipfs://QmScX5vBNHKG9dRcgFcdHhS8xofviwdAVXw2iQ12Tprv6a",
        "ipfs://Qmcsr71W757yWdJTPrkwkq1gMaB9zjdsYHorogawCPyMWA",
        "ipfs://QmadZrzQGvFiB9UC1MRosmNNmvLcM5bYyub4P8ngaazkXy",
        "ipfs://QmUr3Xq8xAARKZDaV3S7M15kPT6mEpLEfsAnGrNsnYc48i",
        "ipfs://QmYWBwG9TgJR5fGmrxbJNhS8KcT68q6zVCchZdj9oBn3qP",
        "ipfs://QmSp8DKqwtrxK3WBheWCfpDV4ofpuTpBkEAzaqD9X1LJ9A",
        "ipfs://QmTKQ3UMQ4vfY2qekb3jgdBdgwDZ33dW3S6ommFJR9iTdH"
        ],[
        "ipfs://QmX4adoJ6qjnpJwjVa3buF4ppMDjRnC2VEPGEvK7HG5aLb",
        "ipfs://QmXMWhbc9JWjNz54QY2u6dQLmmczbeG37Cma6LQMavy9i6",
        "ipfs://QmZQtiA82CjGY7P8Nis3NxLwvAF3j8ReVsxGGN1rErypi2",
        "ipfs://Qmat8uMpKNLMJqmjVYUUkwZQP63Fd2hqe62tXQUE6BD2Cj",
        "ipfs://QmcYfbFPqC5KuQetGxQ5EibSkiMRDzXNhMCo5jJzC9MLku",
        "ipfs://QmdDQ5B8bvUq3DAu84rb8XvG5XeT9w24SKJsWkVtZohEGf",
        "ipfs://QmSwb9Rhz3L9Qn1YynaD6wDQom9w64cUf8SNE5K4hYxdFk",
        "ipfs://QmVEFvcmtxV3oCvfAZAEZin4wAhDGhHyKk9qcatGG3JRSL"
        ],[
        "ipfs://QmZhtqgTFpqALww4HbqbwC8TXNnLCGw8eqjijup72cShmg",
        "ipfs://QmTKAqkmJfvevq7mfTLyaximiZn3qAbStMEqUGHBoadG6P",
        "ipfs://Qmdxy8EFzXap1vdt5Vmdkz1ihdofCkFPFwREBaMpv6ehAW",
        "ipfs://QmRFPzCznfYsuDU1ALzSNkKg2a3k7mYByEnLZAnyTBMJEm",
        "ipfs://QmXqqPPH53cvAqxhLXMU6D7e4YhTagyrAjw45y3xtSQFcf",
        "ipfs://QmPx8fKhP3A2THkfcxKo97xZG5GNbnpNpkFHjxtWky5JKQ",
        "ipfs://QmbcgZNFkNK1mN8kMsjGQAaJC1Jzhxh8cLKL2HVSS1LL73",
        "ipfs://QmdSkikabpEeD94fSY94wJeQS1PD8kwr1HuHvNJ9XR19vF" 
        ]
    ];

    function get(uint part, uint index) view external returns(string memory tokenURI) {
        tokenURI = equipment[part][index];
    }

    
}
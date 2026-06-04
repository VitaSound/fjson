\ Follows theforth.net publishing guidelines:
\   https://theforth.net/guidelines
forth-package
    key-value name fjson
    key-value version 0.2.0
    key-value description Minimal JSON write and read-lite for Gforth (VitaSound tooling, MCP, future fcov)
    key-value license COPL
    key-value main fjson.4th
    key-value fmix ~> 0.7
    key-value flint ~> 0.2
    key-value fcov ~> 0.3
    key-list tags json
    key-list tags gforth
    key-list tags mcp
    key-list dependencies fenum git https://github.com/VitaSound/fenum tag 0.1.1
    key-list dependencies ttester git https://github.com/VitaSound/ttester tag 1.2.1
end-forth-package

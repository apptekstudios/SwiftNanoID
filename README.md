**Simple swift implementation of NanoID.**

Uses common defaults (length 21, alphabet "useandom-26T198340PX75pxJACKVERYMINDBUSHWOLF_GQZbfghjklqvwyzrict")

If needed change length and alphabet:
`NanoID.alphabet = Set("yournewalphabet")`
`NanoID.length = 21`

Create new NanoID:
`let id = NanoID()`

Create from NanoID string:
`let id = try NanoID("pvWSDD0e41rZ5wneWmASZ")`

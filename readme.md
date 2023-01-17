# Subscribestar extractor

A script to extract the Subscribestar content

## Usage

```nim
import std/json
import pkg/subscribestar

let star = extractStar("starname", "cookies here")
echo pretty %*star
```

## License

MIT

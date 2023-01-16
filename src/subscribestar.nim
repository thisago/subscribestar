from std/httpclient import newHttpClient, close, getContent, Http200,
                            newHttpHeaders
from std/strformat import fmt

from pkg/useragent import mozilla
from pkg/util/forStr import between, tryParseInt

import pkg/findxml/findAll


type
  Star* = object
    postsQnt*: int
    name*, userId*: string
    posts*: seq[StarPost]
  StarPost* = object
    name*, description*: string
    videoUrl*: string
    likes*, dislikes*: int

when defined release:
  const url = "https://www.subscribestar.com"
else:
  const url = "http://127.0.0.1:5555/tmp/"

proc extractStar*(starName, cookies: string): Star =
  ## Extracts a Subscribestar user
  let client = newHttpClient(headers = newHttpHeaders({
    "User-Agent": mozilla,
    "Cookie": cookies
  }))
  let body = client.getContent fmt"{url}/{starName}"
  close client
  block extract:
    result.postsQnt = tryParseInt(body.between(" 8 3.58 8 8-3.58 8-8 8z\"/></svg>\n</i>", " posts</div></div>"), -1)
    result.name = body.between("\"profile_main_info-name\">", "</div>")
    result.userId = body.between("data-user-id=\"", "\"")


when isMainModule:
  let star = extractStar("cienciadeverdade", "_personalization_id=eyJfcmFpbHMiOnsibWVzc2FnZSI6IklrZDZOVkEyUWpocWNqWlhNM1I2ZUd0MGNHUlFRMUVpIiwiZXhwIjoiMjAyMy0wMi0xNVQxNTo1OToxNS4wMTRaIiwicHVyIjoiY29va2llLl9wZXJzb25hbGl6YXRpb25faWQifX0%3D--45027e5906d71cad227e993793f38a1fd6325903; auth_tracker_code=eyJfcmFpbHMiOnsibWVzc2FnZSI6IkltMDJkWEprYjFJeVYzVkVaazVNTVZKTFJURXJTRVZHTTFSRkx6WkJkakI0ZEdwVlp6Y3ZSVlpOSzJSSVNHaHhhRmxSVVVKNmVXUkpNbEZZWVhnNU0ydFJXbGhRYmxjd1NrUlhRMmhEUWpnME5ERTRiekppT1VWV01HdFZiV3g1VjFCUVRUWnVlbWx3UlRCdllqUmFiMjlUTUhNMVdHaHJSV3hEWVZaSGMxbHdVbXhSZWtvM0x6RlNVVDA5TFMxWFJraHZWbE5RYTNwak4yeElXRVprTFMweFdrd3hhRnAzZW1kcmVtYzJiSFJyVUVsMlIwRlJQVDBpIiwiZXhwIjoiMjAzMy0wMS0xNlQxNjoxNToxMS45MjdaIiwicHVyIjoiY29va2llLmF1dGhfdHJhY2tlcl9jb2RlIn19--9001f9351bd0e41a865ee3f657c324e609729f45" )
  echo star

from std/httpclient import newHttpClient, close, getContent, Http200,
                            newHttpHeaders
from std/strformat import fmt, `&`
from std/json import parseJson, `{}`, getStr
from std/strutils import replace, split, strip
from std/htmlparser import parseHtml
from std/xmltree import innerText

from pkg/useragent import mozilla
from pkg/util/forStr import between, tryParseInt

# import pkg/findxml/findAll

import subscribestar/entToUtf8

type
  Star* = object
    postsQnt*: int
    name*, userId*, avatar*, username*: string
    posts*: seq[StarPost]
  StarPost* = object
    name*, description*, publishDate*, id*: string
    videoUrl*: string
    likes*, dislikes*: int

when defined release:
  const url = "https://www.subscribestar.com"
else:
  const url = "http://127.0.0.1:5555/tmp/"

func postsApi(limit: int; userId: string): string =
  fmt"https://www.subscribestar.com/posts?limit={limit}&star_id={userId}"

proc extractPosts(star: var Star; cookies: string) =
  ## Extract the posts of Star
  let client = newHttpClient(headers = newHttpHeaders({
    "User-Agent": mozilla,
    "Cookie": cookies,
  }))
  const sep = "%44+_ś%#"
  let
    resp = client.getContent postsApi(star.postsQnt, star.userId)
    json = parseJson resp
    htmls = json{"html"}.getStr.replace("</div></div><div class=\"post is-shown", &"</div></div>{sep}<div class=\"post is-shown").split(sep)
  close client
  for postHtml in htmls:
    var post: StarPost
    let dataGallery = postHtml.between("data-gallery=\"", "\" data-preview=").entToUtf8
    if dataGallery.len > 10:
      let json = dataGallery.parseJson{0}
      block save:
        post.videoUrl = json{"url"}.getStr
        post.id = postHtml.between("data-edit-path=\"/posts/", "/edit\"")
        post.publishDate = postHtml.between(&"<div class=\"post-date\"><a href=\"/posts/{post.id}\">", "</a></div>")
        post.name = postHtml.between("<html><body>\n<h1>", "</h1>")
        post.description = postHtml.
          between("</h1>\n<div>", "</div>\n\n", catchAll = true).
          parseHtml.
          innerText.
          strip
        post.likes = tryParseInt postHtml.between("<span class=\"reaction-title\">Like</span><span class=\"reaction-counter\">(", ")</span>")
        post.dislikes = tryParseInt postHtml.between("<span class=\"reaction-title\">Dislike</span><span class=\"reaction-counter\">(", ")</span>")

    star.posts.add post

proc extractStar*(starName, cookies: string): Star =
  ## Extracts a Subscribestar user
  let client = newHttpClient(headers = newHttpHeaders({
    "User-Agent": mozilla,
    "Cookie": cookies
  }))
  let body = client.getContent fmt"{url}/{starName}"
  close client
  block extractStar:
    result.username = starName
    result.postsQnt = tryParseInt body.between(" 8 3.58 8 8-3.58 8-8 8z\"/></svg>\n</i>", " posts</div></div>")
    result.name = body.between("\"profile_main_info-name\">", "</div>")
    result.userId = body.between("data-user-id=\"", &"\" alt=\"{result.name}").between("data-user-id=\"", "\"")
    result.avatar = body.between(fmt"data-user-id=""{result.userId}"" alt=""{result.name}"" src=""", "\" />")
  
  # when not defined release:
  #   result.postsQnt = 1
  result.extractPosts cookies
  

when isMainModule:
  import std/json
  let star = extractStar("cienciadeverdade", "_personalization_id=eyJfcmFpbHMiOnsibWVzc2FnZSI6IklrZDZOVkEyUWpocWNqWlhNM1I2ZUd0MGNHUlFRMUVpIiwiZXhwIjoiMjAyMy0wMi0xNlQxNToyMDoyMi40MzNaIiwicHVyIjoiY29va2llLl9wZXJzb25hbGl6YXRpb25faWQifX0%3D--b4a3745fe0a7aee170ba5db4384b119d533869bc; auth_tracker_code=eyJfcmFpbHMiOnsibWVzc2FnZSI6IkluVjFPRFpUS3pkUUt6UTRVREZyWkdsb2QwVkJNV05LYURKNVVFTkRXRTFDVFdkT1YzRlNWMVo1T1dRNWRuQlFRWE5QWTBScVpXODNORFJTYVZGdGJtWXpPREpIUXpKWk1rVldNQ3RtWXpsV2VrTmhOVzkwVVU4MVUxSjJlalJzVGtwd1ExUllibU5pVVROdloxbGpXbFV6YlhRMGNYbzNWR2M0U0hSTmFXUTVlaXR4ZVV3NE4zcHBVVDA5TFMxc05rMXdRMFEwZFhVelprMWhSRzVaTFMxMlpHMDJOakZYTUc1MVF6aFhkSEJsTjNseVNHOUJQVDBpIiwiZXhwIjoiMjAzMy0wMS0xN1QxNToyMDoyMi43NjBaIiwicHVyIjoiY29va2llLmF1dGhfdHJhY2tlcl9jb2RlIn19--7f7496b3d73d47a65370f51034c813af73e05e13")
  echo pretty %*star

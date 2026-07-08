# searx/engines/missav.py
"""
MissAV.ws/en engine - JAV video search scraper
"""

from __future__ import annotations

from typing import Any

from lxml import html
from searx.result_types import Video
from searx.engines.types import Engine
from searx.utils import extract_text

base_url: str = "https://missav.ws"
search_path: str = "/en/search/{query}?page={pageno}"

about: dict[str, Any] = {
    "website": base_url + "/",
    "wikidata_id": None,
    "use_official_api": False,
    "require_api_key": False,
    "results": "video",  # optional metadata hint, can be removed
}

paging: bool = True
categories: list[str] = ["videos", "porn"]
safesearch: bool = False
timeout: float = 5.0


def request(query: str, params: dict) -> dict:
    pageno = params.get("pageno", 1)
    search_url = search_path.format(query=query, pageno=pageno)
    params["url"] = base_url + search_url
    return params


def response(resp) -> list[Video]:
    results: list[Video] = []
    dom = html.fromstring(resp.text)

    # Common container for each video item (adjust if site changes)
    for result in dom.xpath('//div[contains(@class, "video-item") or contains(@class, "mb-4") or contains(@class, "relative") or contains(@class, "group")]'):
        try:
            # Title & URL
            title_elem = result.xpath('.//a[contains(@href, "/videos/") or contains(@class, "title")]')
            if not title_elem:
                continue
            title = extract_text(title_elem[0]).strip()
            rel_url = title_elem[0].get("href")
            if not rel_url:
                continue
            url = base_url + rel_url if rel_url.startswith("/") else rel_url

            # Thumbnail (data-src or src, lazy loading common)
            thumb_elem = result.xpath('.//img[@data-src or @src]')
            thumbnail = thumb_elem[0].get("data-src") or thumb_elem[0].get("src") if thumb_elem else None

            # Duration (often in overlay or small text)
            duration_elem = result.xpath('.//span[contains(@class, "duration") or text()="min"]')
            duration = extract_text(duration_elem[0]).strip() if duration_elem else None

            # Views (optional)
            views_elem = result.xpath('.//span[contains(text(), "views") or contains(@class, "views")]')
            views = extract_text(views_elem[0]).strip() if views_elem else None

            results.append(
                Video(
                    url=url,
                    title=title,
                    thumbnail=thumbnail,
                    duration=duration,
                    views=views,
                    # content can be empty or add tags if parsed later
                )
            )
        except Exception:
            # Skip broken items silently
            continue

    return results
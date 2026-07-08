# searx/engines/nsfwph.py
"""
NSFWPH.org - XenForo forum thread search
"""

from __future__ import annotations

from typing import Any

from lxml import html
from searx.engines.types import Engine
from searx.utils import extract_text

base_url: str = "https://nsfwph.org"
search_path: str = "/search/{query}/?quick=1&o=relevance"

about: dict[str, Any] = {
    "website": base_url + "/",
    "use_official_api": False,
    "require_api_key": False,
}

paging: bool = True
categories: list[str] = ["general", "social media"]
safesearch: bool = False
timeout: float = 6.0


def request(query: str, params: dict) -> dict:
    pageno = params.get("pageno", 1)
    if pageno > 1:
        params["url"] = f"{base_url}{search_path.format(query=query)}&page={pageno}"
    else:
        params["url"] = f"{base_url}{search_path.format(query=query)}"
    return params


def response(resp) -> list[dict]:
    results = []
    dom = html.fromstring(resp.text)

    for item in dom.xpath('//div[contains(@class, "structItem")]'):
        try:
            title_elem = item.xpath('.//div[contains(@class, "structItem-title")]//a')
            if not title_elem:
                continue
            title = extract_text(title_elem[0]).strip()
            rel_url = title_elem[0].get("href")
            url = base_url + rel_url if rel_url and not rel_url.startswith("http") else rel_url

            # Snippet from minor row or first post preview
            content_parts = item.xpath('.//div[contains(@class, "structItem-minor") or contains(@class, "message-cell")]//text()')
            content = " ".join(content_parts).strip()[:350].replace("\n", " ")

            if title and url:
                results.append({
                    "url": url,
                    "title": title,
                    "content": content,
                })
        except Exception:
            continue

    return results
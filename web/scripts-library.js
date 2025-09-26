(async function(){
  const fmt = (iso)=> iso ? new Date(iso).toLocaleString([], {
    year:"numeric", month:"short", day:"2-digit", hour:"2-digit", minute:"2-digit"
  }) : "—";

  async function loadManifest(url, mountId){
    const el = document.getElementById(mountId);
    try{
      const res = await fetch(url, { cache: "no-store" });
      if (!res.ok) throw new Error(res.status + " " + res.statusText);
      const data = await res.json();
      const items = Array.isArray(data.items) ? data.items : [];
      el.innerHTML = items.map(it => `
        <article class="card">
          <h3 style="margin:.1em 0 .2em"><a href="${it.html_url}" target="_blank" rel="noopener">${it.name}</a></h3>
          <p class="meta">Last updated: ${fmt(it.updated)} ${it.sha ? "· " + it.sha : ""}</p>
          <div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:6px">
            <a class="btn" href="${it.html_url}" target="_blank" rel="noopener">View on GitHub</a>
            <a class="btn" href="${it.raw_url}"  target="_blank" rel="noopener">Raw file</a>
          </div>
        </article>
      `).join("") || `<p>No files found.</p>`;
    } catch(e) {
      console.error("Manifest load failed for", url, e);
      el.innerHTML = `<p>Load error for <code>${url}</code>: ${e.message}</p>`;
    }
  }

  await loadManifest("https://cdn.jsdelivr.net/gh/DJCastle/homeBrewScripts@main/manifest.json","brew-list");
  await loadManifest("https://cdn.jsdelivr.net/gh/DJCastle/chocolateyScripts@main/manifest.json","choco-list");
})();

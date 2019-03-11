function sortWithoutHTML(a, b) {
  function stripHTML(html) {
    let tmp = document.createElement("DIV");
    tmp.innerHTML = html;
    return tmp.textContent || tmp.innerText || "";
  }
  return stripHTML(a).localeCompare(stripHTML(b))
}
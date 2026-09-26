--!nonstrict
-- Noctalia dictation bar widget (frontend)
-- Pure client: receives JSON state from headless daemon and updates icon color.

local function render(status)
  if type(status) ~= "table" then
    return
  end

  local state = status.state
  if state == "recording" then
    barWidget.setGlyph("microphone-2")
    barWidget.setGlyphColor("primary")
    barWidget.setTooltip("Идет запись... Говорите")
  elseif state == "processing" then
    barWidget.setGlyph("loader")
    barWidget.setGlyphColor("primary")
    barWidget.setTooltip("Обработка речи через Groq AI...")
  else
    barWidget.setGlyph("microphone-2")
    barWidget.setGlyphColor("on_surface_variant")
    barWidget.setTooltip("Диктовка неактивна (кликните для записи)")
  end
end

local function onStatusLine(line)
  if type(line) ~= "string" or line == "" then
    return
  end
  local ok, status = pcall(noctalia.json.decode, line)
  if ok and type(status) == "table" then
    render(status)
  end
end

-- Initial idle state
barWidget.setGlyph("microphone-2")
barWidget.setGlyphColor("on_surface_variant")
barWidget.setText("")
barWidget.setTooltip("Диктовка неактивна (кликните для записи)")

-- Direct binary execution of status --follow stream (no bash wrappers)
noctalia.runStream("noctalia-dictation status --follow", onStatusLine)

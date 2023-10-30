fc = {}

# 基本資料
fc <<<
  "姓名":
    meta: is-required: true
  "出生年":
    meta:
      is-required: true
      term: [{opset: \number, enabled: true, op: \is, msg: '必須是數字'}]
      config: limitation: "請填西元年"
  "聯絡EMAIL":
    meta:
      is-required: true
      term: [ {opset: \string, enabled: true, op: \email, msg: "格式不符", config: {}} ]
  "聯絡電話":
    meta:
      is-required: true
      term: [
        {
          opset:\string, enabled:true, op:\regex, msg:"格式不符",
          config: rule: "^\\d{4}-\\d{6}$|^\\d{2,3}-\\d{7,8}$"
        }
      ]
      config: note: [ "請使用此種格式：02-27458186 或 0912-345678" ]
  "團隊介紹":
    type: \@makeform/textarea
    meta:
      desc: "請簡單介紹你的團隊"
      term: [{opset: \length, enabled: true, op: \lte, msg: '太長了', config: val: 300, method: \simple-word}]
      config:
        limit: "勿超過 300 字"
  "上傳圖片":
    type: \@makeform/image
    meta:
      desc: "上傳圖片"
      
  "計劃簡介":
    type: \@makeform/textarea
    meta:
      desc: "請簡單介紹你的計劃"
      term: [{opset: \length, enabled: true, op: \lte, msg: '太長了', config: val: 300, method: \simple-word}]
      config:
        note: [
          "以計劃目的、受眾、預期效益以及時程的方式描述"
          "建議同時說明與現有其他類似計劃的差異性"
        ]
        limit: "勿超過 300 字"
  "計劃書":
    type: \@makeform/upload
    meta:
      term: [
        {opset: \file, enabled: true, op: \extension, msg: '檔案格式不符', config: str: "pdf"}
        {opset: \file, enabled: true, op: \count-min, msg: '需要至少一個檔案', config: val: 1}
        {opset: \file, enabled: true, op: \size-limit, msg: '檔案太大', config: val: 5 * 1048576}
      ]
      config:
        multiple: true
        note: [
          "請上傳 PDF 檔"
          "檔案大小上限 5MB"
        ]

# 附件資料
fc <<<
  "同意事項":
    type: "@makeform/agreement"
    meta:
      is-required: true
      readonly:  false
      config:
        value: "我已閱讀並接受以上「個人資料同意書」之內容。"
        note: ["記得勾選"]

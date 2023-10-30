fc = {}

fc["參賽資格"] =
  type: \@makeform/checklist
  meta:
    is-required: true
    config:
      items: [
        "具中華民國國籍，或有中華民國之有效居留證"
        "未曾於「國內外之公、私立美術館、商業畫廊、藝術博覽會」舉辦過個展"
        "參加「國內外之公、私立美術館、商業畫廊、藝術博覽會」之聯展，未超過 5 次（意即「參加聯展 0-5 次皆可參加）"
      ]

fc["作品規範"] =
  type: "@makeform/agreement"
  meta:
    is-required: true
    config:
      display: \inline
      value: "我已理解，且作品符合上述規範"

fc["參賽需知"] =
  type: "@makeform/agreement"
  meta:
    is-required: true
    config:
      display: \inline
      value: "我已詳閱並同意遵守上述內容"


fc["真實姓名"] =
  meta: is-required: true

fc["團體名稱"] =
  meta:
    is-required: false
    config: note: ["團體報名者必填。個人報名者請留白"]

fc["性別"] =
  type: \@makeform/radio
  meta:
    is-required: true
    config: values: <[女性 男性 自定義]>

fc["年齡"] =
  type: \@makeform/choice
  meta:
    is-required: true
    config: values: [ "17 歲以下", "18 - 35 歲", "36 - 45 歲", "46 - 55 歲", "56 - 65 歲", "66 歲以上"]

fc["國籍"] =
  type: \@makeform/radio
  meta:
    desc: "同時具中華民國與外國籍之雙重身分者，請選擇「具中華民國國籍」"
    config: values: <[具中華民國國籍 外國籍，具中華民國居留證]>

fc["居住地"] =
  type: \@makeform/choice
  meta:
    is-required: true
    config:
      values: <[
        屏東縣 高雄市 台南市 嘉義縣／市 雲林縣 彰化縣
        南投縣 台中市 苗栗縣 新竹縣／市 桃園市 台北市
        新北市 基隆市 宜蘭縣 花蓮縣 台東縣 澎湖縣 連江縣 金門縣
      ]> 
      other: enabled: true, prompt: "居住於國外，請自行填寫"

fc["電子信箱"] =
  meta:
    is-required: true
    term: [ {opset: \string, enabled: true, op: \email, msg: "格式不符", config: {}} ]

fc["聯絡電話"] =
  meta:
    is-required: true
    term: [
      {
        opset: \string, enabled: true, op: \regex, msg: "格式不符",
        config: rule: "^\\d{4}-\\d{6}$|^\\d{2,3}-\\d{7,8}$"
      }
    ]
    config: note: ["填寫格式：0912-345678／02-23456789"]

fc["作品名稱"] =
  meta: is-required: true

fc["作品說明"] =
  type: \@makeform/textarea
  meta:
    meta: is-required: true
    term: [{
      opset: \length, enabled: true, op: \lte, msg: '長度不符'
      config: val: 500, method: \simple-word
    }]
    config: limitation: "500 字以內"

fc["資訊揭露：影像內容是否使用生成式 AI 技術？"] =
  type: \@makeform/radio
  meta:
    config:
      values: <[是 否]>
      note: ["不影響參賽資格，惟請照實填寫"]

fc["作品上傳"] =
  type: \@makeform/image
  meta:
    is-required: true
    term: [
      # TODO
    ]
    config:
      note: [
        "請上傳 15 - 25 張影像，將視為一組作品"
        "影像須為 jpg 檔，長邊為 3,000 像素"
      ]


fc["個人／團體自述"] =
  type: \@makeform/textarea
  meta:
    is-required: true
    term: [{
      opset: \length, enabled: true, op: \lte, msg: '長度不符'
      config: val: 500, method: \simple-word
    }]
    config: limitation: "（ 500 字以內）"


fc["個人／團體參展經歷"] =
  type: \@makeform/textarea
  meta:
    desc: "請以條列方式敘述，若無則免填"
    is-required: false
    term: [{
      opset: \length, enabled: true, op: \lte, msg: '長度不符'
      config: val: 500, method: \simple-word
    }]
    config:
      limitation: "（ 500 字以內）"

fc["是否具學生身分？"] =
  type: \@makeform/radio
  meta:
    is-required: true
    plugin: [
    * type: \dependency
      config:
        values: ["是"]
        is-required: true
        visible: true
        targets: <[學生證正面]>
    ]
    config:
      values: <[是 否]>
      note: [
        "僅影響報名費用",
        "學生身分定義：就讀中華民國公、私立國中小、高中、高職之在學生，以及大專院校在學學生包含大專、專科、軍警學校及宗教院校，但不包含私人補習班、社區大學、空中大學、空中學院及大專院校附設之進修補習班。學制包含二專、五專、二技、四技、大學、碩士及博士。部別包含日間部、夜間部、進修部（須為上述學制）及在職專班（須為上述學制）"
      ]

fc["學生證正面"] =
  type: \@makeform/upload
  meta:
    title: "學生證正面照片上傳"
    desc: "具學生身分者，請上傳學生證之正面照片"
    is-required: false

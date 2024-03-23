fc = {}

fc["參賽資格"] =
  type: \@makeform/checklist
  meta:
    is-required: true
    config:
      items: [
        "有中華民國國籍，或持中華民國有效居留證，且在台居住超過 183 天之外國籍人士，皆可報名。"
        "未曾於「國內外之公、私立美術館、商業畫廊、藝術博覽會」舉辦個展。"
        "參加「國內外之公、私立美術館、商業畫廊、藝術博覽會」之聯展，不超過 5 次。（意即 0 至 5 次，皆可參加。）"
      ]

fc["作品規範"] =
  type: "@makeform/agreement"
  meta:
    is-required: true
    config:
      display: \inline
      value: "我已詳閱，且作品符合上述規範"

fc["參賽需知"] =
  type: "@makeform/agreement"
  meta:
    is-required: true
    config:
      display: \inline
      value: "我已詳閱，並同意遵守上述內容"


fc["真實姓名"] =
  meta: is-required: true

fc["別名"] =
  meta:
    is-required: false
    config: note: ["填寫別名之參加者，若獲獎將以別名進行公告，不揭露真實姓名。"]

fc["團體名稱"] =
  meta:
    is-required: false
    config: note: ["團體報名者必填，個人報名者請留白。"]

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
    is-required: true
    config: 
      values: <[具中華民國國籍 外國籍，具中華民國有效居留證]>

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

fc["作品簡介"] =
  type: \@makeform/textarea
  meta:
    is-required: true
    term: [{
      opset: \length, enabled: true, op: \lte, msg: '長度不符'
      config: val: 500, method: \simple-word
    }]
    config: note: ["500 字以內"]

fc["創作媒材揭露：影像內容是否源自生成式 AI 工具？"] =
  type: \@makeform/radio
  meta:
    is-required: true
    config:
      values: <[是 否]>
      note: ["不影響參加資格，惟請照實填寫。"]

fc["作品上傳"] =
  type: \@makeform/image
  meta:
    is-required: true
    term: [
    * opset: \file, enabled: true, op: \count-range, msg: '請上傳 15 - 25 張作品圖檔，將視為一組作品。'
      config: min: 15, max: 25
    * opset: \image, enabled: true, op: \long-side, msg: '長邊為 3,000 像素。'
      config: min: 2999, max: 3001
    * opset: \file, enabled: true, op: \extension, msg: '影像須為 jpg 檔'
      config: str: "jpg,jpeg"
    ]
    config:
      multiple: true
      note: [
        "請上傳 15 - 25 張作品圖檔，將視為一組作品。"
        "影像須為 jpg 檔，長邊須為 3,000 像素。"
      ]

fc["上傳作品之展呈示意圖"] =
  type: \@makeform/image
  meta:
    is-required: false
    term: [
    * opset: \image, enabled: true, op: \long-side, msg: '長邊為 3,000 像素。'
      config: min: 3000, max: 3000
    * opset: \file, enabled: true, op: \extension, msg: '影像須為 jpg 檔'
      config: str: "jpg, jpeg"
    ]
    config:
      multiple: true
      note: [
        "非必填。"
        "請以示意圖（至多3張）呈現作品的展示規劃。"
        "展示牆面尺寸：寬 3 公尺、高 2.5 公尺。"
        "影像須為 jpg 檔，長邊須為 3,000 像素。"
      ]

fc["自我介紹"] =
  type: \@makeform/textarea
  meta:
    is-required: true
    term: [{
      opset: \length, enabled: true, op: \lte, msg: '長度不符'
      config: val: 500, method: \simple-word
    }]
    config: note: ["500 字以內"]


fc["參展經歷"] =
  type: \@makeform/textarea
  meta:
    is-required: true
    term: [{
      opset: \length, enabled: true, op: \lte, msg: '長度不符'
      config: val: 500, method: \simple-word
    }]
    config:
      note: [
        "500 字以內"
        "請條列所有參展經歷。若無，請填寫無。"
      ]

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
        disabled: false
        targets: <[學生證正面 報名費-學生]>
    * type: \dependency
      config:
        values: ["否"]
        is-required: true
        visible: true
        disabled: false
        targets: <[報名費-一般]>
    ]
    config:
      values: <[是 否]>
      note: [
        "僅影響報名費用。",
        "學生身分定義：就讀中華民國公、私立國中小、高中、高職之在學生，以及大專院校在學學生包含大專、專科、軍警學校及宗教院校。但不包含私人補習班、社區大學、空中大學、空中學院及大專院校附設之進修補習班。學制包含二專、五專、二技、四技、大學、碩士及博士。部別包含日間部、夜間部、進修部（須為上述學制）及在職專班（須為上述學制）。"
      ]

fc["學生證正面"] =
  type: \@makeform/upload
  meta:
    is-required: false
    disabled: true
    title: "學生證正面照片上傳"
    note: ["具學生身分者，請上傳學生證之正面照片。"]

fc["報名費-一般"] =
  type: {name: \@grantdash/dart, path: \block/widget/payment}
  meta:
    title: "報名費 (一般身份)"
    is-required: true
    config:
      target: "報名費-一般"
      amount: "1000"
      unit: \新台幣

fc["報名費-學生"] =
  type: {name: \@grantdash/dart, path: \block/widget/payment}
  meta:
    title: "報名費 (學生身份)"
    is-required: false
    disabled: true
    config:
      target: "報名費-學生"
      amount: "500"
      unit: \新台幣

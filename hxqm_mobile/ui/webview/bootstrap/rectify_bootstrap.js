/**
 * javaScript to java bridge: RectifyJsToJava.java
 */
var RectifyJsNativeBridge = (function(window) {
	var m = {};
	console.log(" navigator.userAgent " + navigator.userAgent);
	console.log(" navigator.vendor)" + navigator.vendor);
	m.isChromeWebView = /android/.test(navigator.userAgent);
	m.isUiWebView = /iPhone/.test(navigator.userAgent);

	init();
	/**
	 * 加载页面数据
	 */
	m.getData = getData;
	/**
	 * 跳转到图片查看界面
	 */
	m.goPhotoPage = goPhotoPage;
	/**
	 * 保存单位
	 */
	m.saveOrgData = saveOrgData;
	/**
	 * 保存表单
	 */
	m.saveFormData = saveFormData;
	/**
	 * toast
	 */
	m.showToast = showToast;
	/**
	 * 提交按钮
	 */
	m.doSubmit = doSubmit;
	/**
	 * 关闭按钮
	 */
	m.doClose = doClose;
	/**
	 * 退回按钮
	 */
	m.doReturn = doReturn;
	/**
	 * 删除单挑整改责任单位
	 */
	m.delRecord = delRecord;
	return m;
	function init() {
		if (m.isUiWebView) {

			function connectWebViewJavascriptBridge(callback) {
				document.addEventListener('WebViewJavascriptBridgeReady',
						function() {
							callback(WebViewJavascriptBridge)
						}, false)
			}
			connectWebViewJavascriptBridge(registercallback)

		}

	}
	;
	/**
	 * 加载页面数据1
	 */
	function getData(callback) {
		if (this.isChromeWebView) {
			console.log("RectifyJsToJava.getData()");
			var data = RectifyJsToJava.getData();
			console.log(data);
			callback(data);
		}
		if (this.isUiWebView) {
			if (!typeof RectifyJsToObjectiveC === 'undefined') {
				RectifyJsToObjectiveC.callHandler('getData', {}, callback);
			} else {
				registercallback = function(bridge) {
					window.RectifyJsToObjectiveC = bridge;
					RectifyJsToObjectiveC.init(function(message,
							responseCallback) {
						var data = {};
						responseCallback(data)
					})
					RectifyJsToObjectiveC.callHandler('getData', {}, callback);
				}
				document.addEventListener('WebViewJavascriptBridgeReady',
						function() {
							registercallback(WebViewJavascriptBridge)
						}, false)

			}
		}
		if (!this.isChromeWebView && !this.isUiWebView) {
			callback("");
		}
	}
	;
	function goPhotoPage() {
		if (this.isChromeWebView) {
			window.RectifyJsToJava.intentToTableDetailActivity();
		}
		if (this.isUiWebView) {
			RectifyJsToObjectiveC.callHandler('goPhotoPage', {}, {});
		}
	}
	;

	function saveOrgData(dataString) {
		console.log("saveOrgData" + dataString);
		if (this.isChromeWebView) {
			RectifyJsToJava.saveOrgData(dataString);
		}
		if (this.isUiWebView) {
			RectifyJsToObjectiveC.callHandler('saveOrgData', dataString, {});
		}
	}
	;
	function saveFormData(dataString, callback) {

		if (this.isChromeWebView) {
			var result = RectifyJsToJava.saveFormData(dataString);
			callback(result);
		}
		if (this.isUiWebView) {
			RectifyJsToObjectiveC.callHandler('saveFormData', dataString,
					callback);
		}
	}
	function delRecord(id) {
		if (this.isChromeWebView) {
			RectifyJsToJava.delRecord(id);
		}
		if (this.isUiWebView) {
			RectifyJsToObjectiveC.callHandler('delRecord', id, {});
		}
	}
	function showToast(id) {
		if (this.isChromeWebView) {
			RectifyJsToJava.showToast(id);
		}
		if (this.isUiWebView) {
			RectifyJsToObjectiveC.callHandler('showToast', id, {});
		}
	}
	function doSubmit(dataString) {
		if (this.isChromeWebView) {
			RectifyJsToJava.doSubmit(dataString);
		}
		if (this.isUiWebView) {
			RectifyJsToObjectiveC.callHandler('doSubmit', dataString, {});
		}
	}
	function doClose(dataString) {
		if (this.isChromeWebView) {
			RectifyJsToJava.doClose(dataString);
		}
		if (this.isUiWebView) {
			RectifyJsToObjectiveC.callHandler('doClose', dataString, {});
		}
	}
	function doReturn(dataString) {
		if (this.isChromeWebView) {
			RectifyJsToJava.doReturn(dataString);
		}
		if (this.isUiWebView) {
			RectifyJsToObjectiveC.callHandler('doReturn', dataString, {});
		}
	}
})(window);
var registercallback = function(bridge) {
	window.RectifyJsToObjectiveC = bridge;
	RectifyJsToObjectiveC.init(function(message, responseCallback) {
		var data = {};
		responseCallback(data)
	})

}
$(document)
		.ready(
				function() {
					// 该代码解决了iOS的WebView下的弹出框在键盘输入结束隐藏时无法恢复被键盘遮盖区域的bug
					if (navigator.userAgent.match(/iPhone|iPad|iPod/i)) {
						$('.modal')
								.on(
										'show.bs.modal',
										function() {
											// Position modal absolute and bump
											// it down
											// to the scrollPosition
											$(this).css(
													{
														position : 'absolute',
														marginTop : $(window)
																.scrollTop()
																+ 'px',
														bottom : 'auto'
													});
											// Position backdrop absolute and
											// make it
											// span the entire page
											//
											// Also dirty, but we need to tap
											// into the
											// backdrop after Boostrap
											// positions it but before
											// transitions
											// finish.
											//
											setTimeout(
													function() {
														$('.modal-backdrop')
																.css(
																		{
																			position : 'absolute',
																			top : 0,
																			left : 0,
																			width : '100%',
																			height : Math
																					.max(
																							document.body.scrollHeight,
																							document.documentElement.scrollHeight,
																							document.body.offsetHeight,
																							document.documentElement.offsetHeight,
																							document.body.clientHeight,
																							document.documentElement.clientHeight)
																					+ 'px'
																		});
													}, 0);
										});
					}
					/**
					 * 初始化页面数据
					 */
					var pageJson;
					/**
					 * 删除倒计时counter
					 */
					var delcounter = 0;
					/**
					 * 删除倒计时器
					 */
					var delinterval;
					RectifyJsNativeBridge.getData(initPage);
					/**
					 * 表单初始数据 用于判断触发 unload自动保存
					 */
					var originalFormValue;
					$(window).bind('beforeunload', saveFormHandler);

					/**
					 * 初始化页面 填充数据，控制布局
					 */
					function initPage(data) {
						if (RectifyJsNativeBridge.isChromeWebView
								|| RectifyJsNativeBridge.isUiWebView) {
							// native 返回值是json字符串
							pageJson = JSON.parse(data);
						} else {
							// 假数据
							pageJson = initJson;
						}
						$('#MEND_TIME_LIMIT').datepicker({
							format : "yyyy-mm-dd",
							language : "zh-CN",
							keyboardNavigation : false,
							autoclose : true
						});
						$('#editModal').on(
								'hidden.bs.modal',
								function(e) {
									// 窗口关闭时 移除 activeitem
									$("a.list-group-item.activeitem")
											.removeClass("activeitem");
								})
						// 为列表添加点击事件
						$(document)
								.on("click", "a.list-group-item", tapHandler);
						// 查看整改照片
						$(document).on("click", "#viewpic", viewpicHandler);
						// 填写扣分记录 事件
						$(document).on("click", "#newrecord", newrecordHandler);
						// 保存 事件
						$(document).on("click", "#saverecordbtn",
								saverecordHandler);
						// 删除 事件
						$(document).on("click", "#delrecordbtn",
								delrecordHandler);
						// todo 提交事件，校验扣分单位不能为空
						$(document).on("click", "#submitbtn", submitHandler);
						// 关闭 整改
						$(document).on("click", "#closebtn", closeHandler);
						// 退回 整改
						$(document).on("click", "#rejectbtn", rejectHandler);

						// 扣分校验
						$("#ORG_CHECK").bind('input propertychange',
								validateCheckHandler);
						// 扣分校验
						$("#ORG_CHECK_PAYMENT").bind('input propertychange',
								validateCheckHandler);
						// 表单值变化自动保存
						$("#basicData input,select,textarea").bind(
								'input propertychange changeDate blur',
								saveFormHandler);
						// 扣分记录
						if (pageJson.problem_org_list) {
							$.each(pageJson.problem_org_list,
									function(i, item) {
										appendNewOrgRow(item);
									});
						}
						// 整改拍照点列表
						if (pageJson.control_point_list) {
							$.each(pageJson.control_point_list, function(i,
									item) {
								appendControlPoint(item);
							});
						}
						// 扣分记录 附加data
						if (pageJson.problem_org_list) {
							$("a.list-group-item").each(
									function(i, item) {
										$(item).data("data",
												pageJson.problem_org_list[i]);
									});
						}
						// 考核依据
						if (pageJson.basisList) {
							$.each(pageJson.basisList, function(i, item) {
								var option = "<option   value=\""
										+ item.BO_DICT_VAL + "\">"
										+ item.BO_DICT_NAME + "</option>";
								$("#EXAM_BASIS").append(option);
							});
						}
						// 填充表单，注意要在select初始化结束后进行
						if (pageJson.rectityMap) {
							$.each(pageJson.rectityMap, filljsondata);
						}

						originalFormValue = JSON.stringify($("#basicData")
								.serializeObject());
						/*
						 * 根据整改节点控制表单展现，
						 * 发起时隐藏反馈内容，第一二三次退回原因；若有草稿，填充表单数据；显示填写扣分记录按钮；
						 * 审核时隐藏反馈内容，第一二三次退回原因；整改时限，考核依据，备注不可修改；显示填写扣分记录按钮；
						 * 回复时，非退回时隐藏第一二三次退回原因，退回时显示退回原因不可修改；整改时限，考核依据，备注不可修改，反馈内容可填写，；隐藏填写扣分记录按钮；
						 * 确认时整改时限，考核依据，备注，反馈内容不可修改，退回原因可填写，隐藏填写扣分记录按钮；
						 */
						for ( var key in pageJson.ELE_RW) {

							switch (pageJson.ELE_RW[key]) {
							case "0":
								break;
							case "1":
								$("#" + key).setDisabled();
								// $("#" + key).attr("readonly", "readonly");
								// $("#" + key).attr('disabled', 'disabled');
								break;
							case "2":
								$("#" + key).closest(
										"div .form-group,div .col-xs-3").hide();
								break;
							default:
								;
							}
						}
						;
						// console.log(originalFormValue===JSON.stringify($("#basicData").serializeObject()));
					}
					/**
					 * 填充表单
					 */
					function filljsondata(name, val) {
						var $el = $("[id=\"" + name + "\"]"), type = $el
								.attr("type");

						switch (type) {
						case "checkbox":
							$el.prop("checked", val === "0" ? false : true);
							break;
						case "radio":
							$el.filter("[value=\"" + val + "\"]").attr(
									"checked", "checked");
							break;
						default:
							$el.val(val);
						}
					}

					/**
					 * 列表点击事件
					 */
					function tapHandler(event) {
						// 点击到任何element都获取相应的父节点 <a>
						var $parentNode = $(event.target).closest(
								'.list-group-item');
						// 为窗口中内容赋值
						var itemdata = $parentNode.data("data");

						if (itemdata.CAN_EDIT === "1") {
							return;
						}
						// 设定当前点击 为 activeitem
						$parentNode.addClass("activeitem");

						// 处理 单位选择框，去除页面已有选项，包含当前点击选项
						filtrateOrgOptions(itemdata["ORG_NAME"]);
						// 填充表单数据
						$.each(itemdata, filljsondata);
						$("#ORG_CHECK").val(itemdata["ORG_CHECK"]);
						$("#ORG_CHECK_PAYMENT").val(
								itemdata["ORG_CHECK_PAYMENT"]);
						// // 默认禁用保存按钮
						// $("#saverecordbtn").attr("disabled", "disabled");
						// $("#saverecordbtn").removeClass("btn-primary");
						// 编辑时启用删除按钮
						$("#delrecordbtn").show();
						// 编辑时禁用 org_id select
						$("#ORG_ID").attr('disabled', 'disabled');
						;
						// 编辑时显示删除
						$("#delrecordbtn").show();
						// 打开编辑窗口
						$("#editModal").modal({
							keyboard : false
						});
						// 设定为更新状态
						$("#saverecordbtn").data("isupdate", true);
					}
					;
					/**
					 * 添加单位扣分记录行
					 */
					function appendNewOrgRow(item) {
						var str = "<a href=\"#\" class=\"list-group-item\">";
						str += generateOrgInner(item);
						str += " </a>"
						$("#org_list").append(str);
					}
					/**
					 * 生成扣分记录行内容
					 */
					function generateOrgInner(item) {
						var str = "";
						str += "<p>";
						str += item.ORG_NAME;
						str += "</p> "
						str += "<div class=\"row\"> ";
						str += "<div class=\"col-xs-4\"> 扣分： " + item.ORG_CHECK
								+ "</div>";
						str += "<div class=\"col-xs-4\"> 扣款："
								+ item.ORG_CHECK_PAYMENT + "</div>";

						str += item.IS_ORG_MOSTLY_MEND === "1" ? "<div class=\"col-xs-4\">整改主体</div>"
								: "";
						str += "</div>";

						return str;
					}
					/**
					 * 添加单条拍照点照片数
					 */
					function appendControlPoint(item) {
						var str = "<div class=\"list-group-item\">";
						str += "<div class=\"row\"> ";
						str += "<div class=\"col-xs-9\">"
								+ item.POINT_NAME.replace(/，共([0-9]*)张/, "")
								+ "</div>";
						str += "<div class=\"col-xs-3\">" + item.PHOTO_COUNT
								+ " 张</div>";
						str += "</div>";
						str += "</div>";
						$("#point_list").append(str);
					}
					/**
					 * 新增按钮事件
					 */
					function newrecordHandler() {
						var emptydata = {
							"ORG_NAME" : "",
							"BO_PROBLEM_ORG_ID" : "",
							"BO_PROBLEM_ID" : "",
							"ORG_TYPE" : "",
							"ORG_ID" : "",
							"ORG_CHECK" : "",
							"ORG_CHECK_PAYMENT" : "",
							"IS_ORG_MOSTLY_MEND" : "",
							"DEDUCTION_TYPE" : ""
						};
						// 处理 单位选择框，去除页面已有选项，包含当前点击选项（新增视为空）
						filtrateOrgOptions(filljsondata["ORG_NAME"]);

						$.each(emptydata, filljsondata);
						// 默认选中第一个
						$("#ORG_ID option:first").attr("selected", "selected");
						// 新增时隐藏删除按钮
						$("#delrecordbtn").hide();
						// 默认禁用保存按钮
						$("#saverecordbtn").attr("disabled", "disabled");
						$("#saverecordbtn").removeClass("btn-primary");
						// 启用选择
						$("#ORG_ID").removeAttr("disabled");

						// 打开编辑窗口
						$("#editModal").modal({
							keyboard : false
						});

						// 设定为 非 更新状态
						$("#saverecordbtn").data("isupdate", false);
					}
					/**
					 * 过滤待选责任单位，初始化 ORG_ID 下拉框 去除页面已有选项，包含当前点击选项（新增视为空）
					 */
					function filtrateOrgOptions(currentTaped) {
						$("#ORG_ID").html("");
						$
								.each(
										pageJson.org_list,
										function(i, org) {
											var match = false;
											$("#org_list p")
													.each(
															function() {
																if ($(this)
																		.text() === org.ORG_NAME
																		&& $(
																				this)
																				.text() !== currentTaped) {
																	match = true;
																	return false;
																}
															});
											if (match) {
												return true;
											} else {
												var orgoption = "<option   value=\""
														+ org.ORG_ID
														+ "\">"
														+ org.ORG_NAME
														+ "</option>";
												$("#ORG_ID").append(orgoption);
											}
										});
					}

					/**
					 * 保存按钮点击事件
					 */
					function saverecordHandler() {
						var newdata = {
							"BO_PROBLEM_ORG_ID" : $(
									"a.list-group-item.activeitem")
									.data("data") ? $(
									"a.list-group-item.activeitem")
									.data("data").BO_PROBLEM_ORG_ID : "",
							"ORG_NAME" : $("#ORG_ID option:selected").text(),
							"ORG_ID" : $("#ORG_ID").val(),
							"ORG_CHECK" : $("#ORG_CHECK").val(),
							"ORG_CHECK_PAYMENT" : $("#ORG_CHECK_PAYMENT").val(),
							"IS_ORG_MOSTLY_MEND" : $("#IS_ORG_MOSTLY_MEND")
									.prop("checked") ? "1" : "0"

						};
						// 添加或修改 整改主体 行
						if ($("#saverecordbtn").data("isupdate")) {
							// 更新
							$("a.list-group-item.activeitem").html(
									generateOrgInner(newdata));
							$("a.list-group-item.activeitem").data("data",
									newdata);
						} else {
							// 添加
							appendNewOrgRow(newdata);
							newdata.BO_PROBLEM_ORG_ID = Math.uuid();
							$("a.list-group-item").last().data("data", newdata);
						}
						// 关闭编辑窗口
						$("#editModal").modal("hide");
						RectifyJsNativeBridge.saveOrgData(JSON
								.stringify(newdata));
					}

					/**
					 * 删除提示
					 */
					function delrecordHandler() {
						if (delcounter > 0) {
							$("#delalert").addClass("hidden");
							actualDelete();
						} else {
							$("#delalert").removeClass("hidden");
							delcounter = 5;
							$("#count").html("(" + delcounter + ")");
							delinterval = setInterval(function() {
								delcounter--;
								$("#count").html("(" + delcounter + ")");
								if (delcounter <= 0) {
									$("#delalert").addClass("hidden");
									$("#count").html("");
									clearInterval(delinterval);
								}
							}, 1000);
						}

					}
					/**
					 * actually删除
					 */
					function actualDelete() {
						$("#count").html("");
						clearInterval(delinterval);
						RectifyJsNativeBridge
								.delRecord($("a.list-group-item.activeitem")
										.data("data").BO_PROBLEM_ORG_ID);
						$("a.list-group-item.activeitem").remove();
						$("#editModal").modal("hide");
					}
					/**
					 * 提交
					 */
					function submitHandler() {
						console.log("提交");
						RectifyJsNativeBridge.doSubmit(JSON.stringify($(
								"#basicData").serializeObject()));
					}
					/**
					 * 查看整改照片
					 */
					function viewpicHandler() {
						console.log("查看整改照片");
						RectifyJsNativeBridge.goPhotoPage();
					}
					/**
					 * 保存表单
					 */
					function saveFormHandler() {

						// RectifyJsNativeBridge.showToast(JSON.stringify($("#basicData").serializeObject())
						// + " "
						// + originalFormValue);
						if ($("#basicData").serializeObject() !== originalFormValue) {
							RectifyJsNativeBridge.saveFormData(JSON
									.stringify($("#basicData")
											.serializeObject()), function() {
							});
						}
					}
					/**
					 * 关闭整改
					 */
					function closeHandler() {
						RectifyJsNativeBridge.doClose(JSON.stringify($(
								"#basicData").serializeObject()));
					}
					/**
					 * 退回整改
					 */
					function rejectHandler() {
						RectifyJsNativeBridge.doReturn(JSON.stringify($(
								"#basicData").serializeObject()));
					}
					/**
					 * 扣分扣款数字校验
					 */
					function validateCheckHandler() {

						var partten1 = /^(-?\d+)(\.\d+)?$/; // 正数或负数
						var partten2 = /[^-+.0-9]/gi;// -+.0-9以外的字符
						var value = $(this).val();
						var stripped = value.replace(partten2, '');
						$(this).val(stripped);
						var illgialInput = false;
						$("#editModal input[type='text']").each(
								function() {
									if ($(this).val() === ""
											|| !partten1.test($(this).val())) {
										illgialInput = true;
										return false;
									}
								});
						if (illgialInput) {
							$("#saverecordbtn").attr("disabled", "disabled");
							$("#saverecordbtn").removeClass("btn-primary");
						} else {
							$("#saverecordbtn").removeAttr("disabled");
							$("#saverecordbtn").addClass("btn-primary");
						}

					}
				});
(function() {
	// Private array of chars to use
	var CHARS = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
			.split('');

	Math.uuid = function(len, radix) {
		var chars = CHARS, uuid = [], i;
		radix = radix || chars.length;

		if (len) {
			// Compact form
			for (i = 0; i < len; i++)
				uuid[i] = chars[0 | Math.random() * radix];
		} else {
			// rfc4122, version 4 form
			var r;

			// rfc4122 requires these characters
			uuid[8] = uuid[13] = uuid[18] = uuid[23] = '-';
			uuid[14] = '4';

			// Fill in random data. At i==19 set the high bits of clock sequence
			// as
			// per rfc4122, sec. 4.1.5
			for (i = 0; i < 36; i++) {
				if (!uuid[i]) {
					r = 0 | Math.random() * 16;
					uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r];
				}
			}
		}

		return uuid.join('');
	}
})();
$.fn.setDisabled = function() {
	if ($(this).is('select')) {
		var mtext = $(this).find('option:selected').text();
		var mvalue = $(this).val();
		var mid = $(this).attr("id");

		$(this).parent().append(
				"<input type=\"hidden\" value=\"" + mvalue + "\" name=\"" + mid
						+ "\" id=\"" + mid + "\">");
		$(this).parent().append(
				"<input type=\"text\" value=\"" + mtext
						+ "\"  readonly=\"readonly\" class=\"form-control\">");
		$(this).remove();
	} else {
		$(this).attr("readonly", "readonly");
		$(this).attr('disabled', 'disabled');
	}
}

$.fn.serializeObject = function() {
	var o = {};
	// var a = this.serializeArray();
	$(this)
			.find(
					'input[type="hidden"], input[type="text"], input[type="password"], input[type="checkbox"]:checked, input[type="radio"]:checked, select,textarea')
			.each(
					function() {
						if ($(this).attr('type') == 'hidden') { // if checkbox
							// is
							// checked do not take
							// the hidden field
							var $parent = $(this).parent();
							var $chb = $parent
									.find('input[type="checkbox"][name="'
											+ this.name.replace(/\[/g, '\[')
													.replace(/\]/g, '\]')
											+ '"]');
							if ($chb != null) {
								if ($chb.prop('checked'))
									return;
							}
						}
						if (this.name === null || this.name === undefined
								|| this.name === '')
							return;
						var elemValue = null;
						if ($(this).is('select')) {
							elemValue = $(this).find('option:selected').val();
						} else if ($(this).is('textarea')) {
							elemValue = $(this).val();
						} else
							elemValue = this.value;

						if (o[this.name] !== undefined) {
							if (!o[this.name].push) {
								o[this.name] = [ o[this.name] ];
							}
							o[this.name].push(elemValue || '');
						} else {
							o[this.name] = elemValue || '';
						}
					});
	return o;
}

const NATIVE_HOST_CONFUSE = "com.apptools.confuse.material";
const TARGET_URL_CONFUSE = "https://xx1ch0v03wd.feishu.cn/wiki/U197wBclBiHpzVkTISEc9jb0nHb?table=tblxo7NzaOIzo7yz&view=vewMnpNgGD";
const DOCUMENT_MARKER_CONFUSE = "U197wBclBiHpzVkTISEc9jb0nHb";
const TABLE_MARKER_CONFUSE = "table=tblxo7NzaOIzo7yz";
const BACKEND_LOGIN_URL_CONFUSE = "https://admin.joyhappier.com/login";
const BACKEND_PACKAGE_URL_CONFUSE = "https://admin.joyhappier.com/app_package";
const BACKEND_PAGE_TIMEOUT_SECONDS_CONFUSE = 90;
const BACKEND_DIALOG_SETTLE_DELAY_MILLISECONDS_CONFUSE = 1200;
const AGREEMENT_GENERATOR_URLS_CONFUSE = {
    privacy: "https://app.freeprivacypolicy.com/wizard/privacy-policy",
    terms: "https://app.freeprivacypolicy.com/wizard/terms-conditions",
    eula: "https://app.freeprivacypolicy.com/wizard/eula"
};
const AGREEMENT_NAMES_CONFUSE = {
    privacy: "隐私政策",
    terms: "使用条款",
    eula: "最终用户许可协议"
};
const FIELD_KEYS_CONFUSE = {
    "UI编号": "uiNumber_confuse",
    "UI 编号": "uiNumber_confuse",
    "开发者账号": "developerAccount_confuse",
    "软件名": "softwareName_confuse",
    "bundle_id": "bundleID_confuse",
    "appid": "appID_confuse",
    "商店审核账号密码": "storeReviewCredential_confuse",
    "手机号": "phoneNumber_confuse",
    "银行卡": "bankCard_confuse",
    "路由ABA": "routingABA_confuse"
};

let nativePort_confuse = null;
let reconnectTimer_confuse = null;
let activeTaskID_confuse = null;

/** 连接桌面应用安装的原生消息宿主，并注册任务监听。 */
function connectNativeHost_confuse() {
    if (nativePort_confuse) return;
    try {
        nativePort_confuse = chrome.runtime.connectNative(NATIVE_HOST_CONFUSE);
        nativePort_confuse.onMessage.addListener((message_confuse) => {
            handleNativeMessage_confuse(message_confuse);
        });
        nativePort_confuse.onDisconnect.addListener(() => {
            nativePort_confuse = null;
            scheduleReconnect_confuse();
        });
    } catch (error_confuse) {
        console.error("无法连接 App Tools 原生消息服务：", error_confuse);
        nativePort_confuse = null;
        scheduleReconnect_confuse();
    }
}

/** 延迟重连原生消息宿主，避免扩展后台频繁创建进程。 */
function scheduleReconnect_confuse() {
    if (reconnectTimer_confuse) return;
    reconnectTimer_confuse = setTimeout(() => {
        reconnectTimer_confuse = null;
        connectNativeHost_confuse();
    }, 3000);
}

/** 将结构化事件发送给原生消息宿主。 */
function postNativeMessage_confuse(message_confuse) {
    if (!nativePort_confuse) {
        throw new Error("App Tools 原生消息服务未连接。");
    }
    nativePort_confuse.postMessage(message_confuse);
}

/** 接收桌面任务并保证同一时间只运行一个浏览器自动化流程。 */
async function handleNativeMessage_confuse(message_confuse) {
    const command_confuse = message_confuse.command_confuse;
    if (![
        "read_material_confuse",
        "generate_agreements_confuse",
        "read_backend_configuration_confuse"
    ].includes(command_confuse)) return;
    const taskID_confuse = String(message_confuse.task_id_confuse || "");
    if (!taskID_confuse) return;
    if (activeTaskID_confuse) {
        sendFailure_confuse(taskID_confuse, "已有浏览器自动化任务正在执行，请稍后重试。");
        return;
    }
    activeTaskID_confuse = taskID_confuse;
    try {
        if (command_confuse === "read_material_confuse") {
            await runMaterialTask_confuse(message_confuse);
        } else if (command_confuse === "generate_agreements_confuse") {
            await runAgreementTask_confuse(message_confuse);
        } else {
            await runBackendConfigurationTask_confuse(message_confuse);
        }
    } catch (error_confuse) {
        sendFailure_confuse(taskID_confuse, error_confuse.message || "Chrome 浏览器自动化失败。");
    } finally {
        activeTaskID_confuse = null;
    }
}

/**
 * 登录苹果马甲包后台，按 Bundle ID 查找项目并读取合包配置。
 * 参数：task_confuse 包含任务编号、后台凭据和目标 Bundle ID。
 * 返回值：Promise<void>，结果通过原生消息回传。
 * 异常：登录、搜索或配置字段读取失败时抛出错误。
 */
async function runBackendConfigurationTask_confuse(task_confuse) {
    const taskID_confuse = String(task_confuse.task_id_confuse || "");
    const account_confuse = String(task_confuse.account_confuse || "").trim();
    const password_confuse = String(task_confuse.password_confuse || "");
    const twoFactorCode_confuse = String(task_confuse.twoFactorCode_confuse || "").trim();
    const bundleID_confuse = String(task_confuse.bundleID_confuse || "").trim();
    if (!taskID_confuse || !account_confuse || !password_confuse || !twoFactorCode_confuse || !bundleID_confuse) {
        throw new Error("后台配置请求缺少账号、密码、2FA 或 Bundle ID。");
    }

    sendProgress_confuse(taskID_confuse, "浏览器助手已连接，正在定位苹果马甲包后台。", 0.18);
    const target_confuse = await acquireBackendTab_confuse();
    try {
        sendProgress_confuse(taskID_confuse, "正在检查后台登录状态。", 0.26);
        await ensureBackendLogin_confuse(
            target_confuse.debuggee_confuse,
            account_confuse,
            password_confuse,
            twoFactorCode_confuse
        );
        sendProgress_confuse(taskID_confuse, "登录成功，正在打开苹果马甲包列表。", 0.38);
        await openBackendPackageList_confuse(target_confuse.debuggee_confuse);
        sendProgress_confuse(taskID_confuse, `正在按 Bundle ID 查找项目：${bundleID_confuse}`, 0.50);
        await searchBackendProject_confuse(target_confuse.debuggee_confuse, bundleID_confuse);
        await scrollBackendTableToEnd_confuse(target_confuse.debuggee_confuse);
        const hasFacebook_confuse = await backendHasFacebook_confuse(
            target_confuse.debuggee_confuse,
            bundleID_confuse
        );

        sendProgress_confuse(taskID_confuse, "已找到唯一项目，正在读取域名配置。", 0.64);
        const domainConfiguration_confuse = await readBackendDomains_confuse(
            target_confuse.debuggee_confuse,
            bundleID_confuse
        );
        sendProgress_confuse(taskID_confuse, "正在读取 AppsFlyer 和 Facebook 配置。", 0.80);
        const appConfiguration_confuse = await readBackendAppConfiguration_confuse(
            target_confuse.debuggee_confuse,
            bundleID_confuse
        );

        const requiredValues_confuse = [
            appConfiguration_confuse.AppsFlyerDevKey,
            appConfiguration_confuse.AppsFlyerAppId,
            domainConfiguration_confuse.configurationDomain_confuse,
            domainConfiguration_confuse.requestDomain_confuse
        ];
        if (requiredValues_confuse.some((value_confuse) => !String(value_confuse || "").trim())) {
            throw new Error("后台项目缺少 AppsFlyerDevKey、AppsFlyerAppId、配置域名或网页域名。")
        }
        const facebookValues_confuse = hasFacebook_confuse
            ? [
                appConfiguration_confuse.FacebookAppID,
                appConfiguration_confuse.FacebookClientToken,
                appConfiguration_confuse.FacebookDisplayName
            ]
            : ["0", "0", "0"];
        if (hasFacebook_confuse && facebookValues_confuse.some((value_confuse) => !String(value_confuse || "").trim())) {
            throw new Error("后台标签包含 FB，但 Facebook 配置字段不完整。")
        }

        postNativeMessage_confuse({
            task_id_confuse: taskID_confuse,
            event_confuse: "result",
            state_confuse: "completed",
            message_confuse: "后台合包配置读取完成。",
            progress_confuse: 1,
            ok_confuse: true,
            configuration_confuse: {
                bundleID_confuse: bundleID_confuse,
                appsFlyerDevKey_confuse: String(appConfiguration_confuse.AppsFlyerDevKey).trim(),
                appleAppID_confuse: String(appConfiguration_confuse.AppsFlyerAppId).trim(),
                configurationDomain_confuse: domainConfiguration_confuse.configurationDomain_confuse,
                requestDomain_confuse: domainConfiguration_confuse.requestDomain_confuse,
                facebookAppID_confuse: String(facebookValues_confuse[0]).trim(),
                facebookClientToken_confuse: String(facebookValues_confuse[1]).trim(),
                facebookDisplayName_confuse: String(facebookValues_confuse[2]).trim(),
                hasFacebook_confuse: hasFacebook_confuse
            }
        });
    } finally {
        await closeBackendDialog_confuse(target_confuse.debuggee_confuse);
        await detachDebugger_confuse(target_confuse.debuggee_confuse);
    }
}

/**
 * 获取当前 Chrome 中的后台标签页，未打开时在当前窗口新建登录页。
 * 参数：无。
 * 返回值：后台标签页和调试目标。
 * 异常：标签页无法创建或调试器无法附加时抛出错误。
 */
async function acquireBackendTab_confuse() {
    const tabs_confuse = await queryTabs_confuse({ url: "https://admin.joyhappier.com/*" });
    const sortedTabs_confuse = tabs_confuse.sort((left_confuse, right_confuse) => {
        const leftPriority_confuse = String(left_confuse.url || "").includes("/app_package") ? 0 : 1;
        const rightPriority_confuse = String(right_confuse.url || "").includes("/app_package") ? 0 : 1;
        return leftPriority_confuse - rightPriority_confuse;
    });
    for (const tab_confuse of sortedTabs_confuse) {
        try {
            const debuggee_confuse = { tabId: tab_confuse.id };
            await attachDebugger_confuse(debuggee_confuse);
            await sendCommand_confuse(debuggee_confuse, "Page.enable");
            await sendCommand_confuse(debuggee_confuse, "Runtime.enable");
            await activateTab_confuse(tab_confuse);
            return { tab_confuse: tab_confuse, debuggee_confuse: debuggee_confuse };
        } catch (_error_confuse) {
            continue;
        }
    }

    const activeTabs_confuse = await queryTabs_confuse({ active: true, lastFocusedWindow: true });
    const properties_confuse = { url: BACKEND_LOGIN_URL_CONFUSE, active: true };
    if (activeTabs_confuse[0] && typeof activeTabs_confuse[0].windowId === "number") {
        properties_confuse.windowId = activeTabs_confuse[0].windowId;
    }
    const tab_confuse = await createTab_confuse(properties_confuse);
    await waitForTabLoad_confuse(
        tab_confuse.id,
        BACKEND_PAGE_TIMEOUT_SECONDS_CONFUSE,
        "后台登录页面加载超时。"
    );
    const debuggee_confuse = { tabId: tab_confuse.id };
    try {
        await attachDebugger_confuse(debuggee_confuse);
        await sendCommand_confuse(debuggee_confuse, "Page.enable");
        await sendCommand_confuse(debuggee_confuse, "Runtime.enable");
    } catch (_error_confuse) {
        throw new Error("无法控制后台标签页，请关闭页面上的调试提示后重试。");
    }
    await activateTab_confuse(tab_confuse);
    return { tab_confuse: tab_confuse, debuggee_confuse: debuggee_confuse };
}

/**
 * 在登录页填写账号、密码和 2FA；已有登录会话时直接返回。
 * 参数：debuggee_confuse 为后台页，后三项为用户输入的登录凭据。
 * 返回值：Promise<void>。
 * 异常：输入框、登录按钮不存在或登录未完成时抛出错误。
 */
async function ensureBackendLogin_confuse(
    debuggee_confuse,
    account_confuse,
    password_confuse,
    twoFactorCode_confuse
) {
    const isLoggedIn_confuse = await evaluate_confuse(
        debuggee_confuse,
        "location.pathname.includes('/app_package') && document.body.innerText.includes('苹果马甲包')"
    );
    if (isLoggedIn_confuse) return;

    const hasLoginForm_confuse = await evaluate_confuse(
        debuggee_confuse,
        "!!document.querySelector(\"input[placeholder*='登录账号'], input[placeholder*='账号']\")"
    );
    if (!hasLoginForm_confuse) {
        await sendCommand_confuse(debuggee_confuse, "Page.navigate", { url: BACKEND_LOGIN_URL_CONFUSE });
        await waitForExpression_confuse(
            debuggee_confuse,
            "!!document.querySelector(\"input[placeholder*='登录账号'], input[placeholder*='账号']\")",
            20,
            "后台登录表单加载超时。"
        );
    }

    const credentialsJSON_confuse = JSON.stringify({
        account_confuse: account_confuse,
        password_confuse: password_confuse,
        twoFactorCode_confuse: twoFactorCode_confuse
    });
    const submitted_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const credentials_confuse = ${credentialsJSON_confuse};
        const visible_confuse = (element_confuse) => !!element_confuse
            && !!(element_confuse.offsetWidth || element_confuse.offsetHeight || element_confuse.getClientRects().length);
        const inputs_confuse = Array.from(document.querySelectorAll('input')).filter(visible_confuse);
        const accountInput_confuse = inputs_confuse.find((input_confuse) =>
            String(input_confuse.placeholder || '').includes('账号')) || inputs_confuse[0];
        const passwordInput_confuse = inputs_confuse.find((input_confuse) =>
            input_confuse.type === 'password' || String(input_confuse.placeholder || '').includes('密码')) || inputs_confuse[1];
        const twoFactorInput_confuse = inputs_confuse.find((input_confuse) =>
            String(input_confuse.placeholder || '').toUpperCase().includes('2FA')) || inputs_confuse[2];
        if (!accountInput_confuse || !passwordInput_confuse || !twoFactorInput_confuse) return false;
        const setValue_confuse = (input_confuse, value_confuse) => {
            const descriptor_confuse = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value');
            descriptor_confuse.set.call(input_confuse, value_confuse);
            input_confuse.dispatchEvent(new Event('input', { bubbles: true }));
            input_confuse.dispatchEvent(new Event('change', { bubbles: true }));
        };
        setValue_confuse(accountInput_confuse, credentials_confuse.account_confuse);
        setValue_confuse(passwordInput_confuse, credentials_confuse.password_confuse);
        setValue_confuse(twoFactorInput_confuse, credentials_confuse.twoFactorCode_confuse);
        const loginButton_confuse = Array.from(document.querySelectorAll('button')).find((button_confuse) =>
            visible_confuse(button_confuse) && String(button_confuse.textContent || '').trim() === '登录'
        );
        if (!loginButton_confuse) return false;
        loginButton_confuse.click();
        return true;
    })()`);
    if (!submitted_confuse) throw new Error("无法填写或提交后台登录信息，请检查登录页结构。")
    await waitForExpression_confuse(
        debuggee_confuse,
        `(() => {
            const bodyText_confuse = String(document.body?.innerText || '');
            const loginForm_confuse = document.querySelector(
                "input[placeholder*='登录账号'], input[placeholder*='账号']"
            );
            const loginPath_confuse = location.pathname.includes('/login');
            const homeMarker_confuse = bodyText_confuse.includes('首页')
                || bodyText_confuse.includes('马甲包')
                || bodyText_confuse.includes('登录成功');
            return !loginPath_confuse && !loginForm_confuse && homeMarker_confuse;
        })()`,
        BACKEND_PAGE_TIMEOUT_SECONDS_CONFUSE,
        "后台登录未完成，请检查账号、密码和 2FA 是否正确。"
    );
}

/**
 * 打开苹果马甲包列表并等待 VXE 数据表加载。
 * 参数：debuggee_confuse 为后台页调试目标。
 * 返回值：Promise<void>。
 * 异常：页面导航或数据表加载超时时抛出错误。
 */
async function openBackendPackageList_confuse(debuggee_confuse) {
    const isPackagePage_confuse = await evaluate_confuse(
        debuggee_confuse,
        "location.pathname.includes('/app_package')"
    );
    if (!isPackagePage_confuse) {
        await sendCommand_confuse(debuggee_confuse, "Page.navigate", { url: BACKEND_PACKAGE_URL_CONFUSE });
    }
    await waitForExpression_confuse(
        debuggee_confuse,
        "document.body.innerText.includes('bundle_id') && !!document.querySelector('.vxe-body--row')",
        BACKEND_PAGE_TIMEOUT_SECONDS_CONFUSE,
        "苹果马甲包列表加载超时。"
    );
}

/**
 * 使用后台搜索弹层按 Bundle ID 筛选，并校验唯一数据行。
 * 参数：debuggee_confuse 为后台页，bundleID_confuse 为目标 Bundle ID。
 * 返回值：Promise<void>。
 * 异常：搜索控件不存在、无结果或结果不唯一时抛出错误。
 */
async function searchBackendProject_confuse(debuggee_confuse, bundleID_confuse) {
    const bundleJSON_confuse = JSON.stringify(bundleID_confuse);
    const opened_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const visible_confuse = (element_confuse) => !!element_confuse
            && !!(element_confuse.offsetWidth || element_confuse.offsetHeight || element_confuse.getClientRects().length);
        const labels_confuse = Array.from(document.querySelectorAll('*')).filter((element_confuse) =>
            visible_confuse(element_confuse)
                && element_confuse.children.length === 0
                && String(element_confuse.textContent || '').trim() === 'BundleId'
        );
        if (labels_confuse.some((label_confuse) => label_confuse.parentElement?.querySelector('input'))) return true;
        const button_confuse = Array.from(document.querySelectorAll('button')).find((item_confuse) =>
            visible_confuse(item_confuse) && String(item_confuse.textContent || '').trim().endsWith('搜索')
        );
        if (!button_confuse) return false;
        button_confuse.click();
        return true;
    })()`);
    if (!opened_confuse) throw new Error("后台页面中未找到搜索按钮。")
    await waitForExpression_confuse(
        debuggee_confuse,
        "Array.from(document.querySelectorAll('*')).some((element_confuse) => element_confuse.children.length === 0 && String(element_confuse.textContent || '').trim() === 'BundleId' && element_confuse.parentElement?.querySelector('input'))",
        10,
        "后台 BundleId 搜索项加载超时。"
    );

    const searched_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const visible_confuse = (element_confuse) => !!element_confuse
            && !!(element_confuse.offsetWidth || element_confuse.offsetHeight || element_confuse.getClientRects().length);
        const label_confuse = Array.from(document.querySelectorAll('*')).find((element_confuse) =>
            visible_confuse(element_confuse)
                && element_confuse.children.length === 0
                && String(element_confuse.textContent || '').trim() === 'BundleId'
                && element_confuse.parentElement?.querySelector('input')
        );
        const container_confuse = label_confuse?.closest('.el-form-item') || label_confuse?.parentElement;
        const input_confuse = container_confuse?.querySelector('input');
        if (!input_confuse) return false;
        const descriptor_confuse = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value');
        descriptor_confuse.set.call(input_confuse, ${bundleJSON_confuse});
        input_confuse.dispatchEvent(new Event('input', { bubbles: true }));
        input_confuse.dispatchEvent(new Event('change', { bubbles: true }));
        const popover_confuse = label_confuse.closest('.el-popover') || label_confuse.parentElement?.parentElement;
        const searchButton_confuse = Array.from(popover_confuse?.querySelectorAll('button') || []).find((button_confuse) =>
            visible_confuse(button_confuse) && String(button_confuse.textContent || '').trim() === '搜索'
        );
        if (!searchButton_confuse) return false;
        searchButton_confuse.click();
        return true;
    })()`);
    if (!searched_confuse) throw new Error("无法填写 BundleId 或执行后台搜索。")
    await waitForExpression_confuse(
        debuggee_confuse,
        `(() => {
            const rows_confuse = Array.from(document.querySelectorAll('.vxe-body--row')).filter((row_confuse) =>
                Array.from(row_confuse.querySelectorAll('td')).some((cell_confuse) =>
                    String(cell_confuse.textContent || '').trim() === ${bundleJSON_confuse}
                )
            );
            return new Set(rows_confuse.map((row_confuse) => row_confuse.dataset.rowid || row_confuse.innerText)).size === 1;
        })()`,
        BACKEND_PAGE_TIMEOUT_SECONDS_CONFUSE,
        `后台未找到 Bundle ID 为 ${bundleID_confuse} 的唯一项目。`
    );
}

/**
 * 将苹果马甲包数据表的横向滚动位置移动到最右侧。
 * 参数：debuggee_confuse 为后台列表页调试目标。
 * 返回值：Promise<void>。
 * 异常：页面没有横向滚动容器时不抛出异常，后续读取继续使用当前表格。
 */
async function scrollBackendTableToEnd_confuse(debuggee_confuse) {
    await evaluate_confuse(debuggee_confuse, `(() => {
        const candidates_confuse = Array.from(document.querySelectorAll('*')).filter((element_confuse) =>
            element_confuse.scrollWidth > element_confuse.clientWidth + 8
                && element_confuse.scrollHeight >= element_confuse.clientHeight
        );
        let changedCount_confuse = 0;
        for (const element_confuse of candidates_confuse) {
            const maximumScrollLeft_confuse = Math.max(
                0,
                element_confuse.scrollWidth - element_confuse.clientWidth
            );
            if (maximumScrollLeft_confuse <= 0) continue;
            element_confuse.scrollLeft = maximumScrollLeft_confuse;
            element_confuse.dispatchEvent(new Event('scroll', { bubbles: true }));
            changedCount_confuse += 1;
        }
        return changedCount_confuse;
    })()`);
    await delay_confuse(BACKEND_DIALOG_SETTLE_DELAY_MILLISECONDS_CONFUSE);
}

/**
 * 根据目标行“标签”列判断项目是否带有 Facebook。
 * 参数：debuggee_confuse 为后台页，bundleID_confuse 为目标 Bundle ID。
 * 返回值：标签包含“有FB”时返回 true。
 * 异常：目标行或标签列不存在时抛出错误。
 */
async function backendHasFacebook_confuse(debuggee_confuse, bundleID_confuse) {
    const bundleJSON_confuse = JSON.stringify(bundleID_confuse);
    const result_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const row_confuse = Array.from(document.querySelectorAll('.vxe-body--row')).find((item_confuse) =>
            Array.from(item_confuse.querySelectorAll('td')).some((cell_confuse) =>
                String(cell_confuse.textContent || '').trim() === ${bundleJSON_confuse}
            )
        );
        const header_confuse = Array.from(document.querySelectorAll('th')).find((item_confuse) =>
            String(item_confuse.textContent || '').trim() === '标签'
        );
        const columnClass_confuse = Array.from(header_confuse?.classList || []).find((name_confuse) => name_confuse.startsWith('col_'));
        const text_confuse = columnClass_confuse
            ? String(row_confuse?.querySelector('.' + columnClass_confuse)?.textContent || '').trim()
            : '';
        return { found_confuse: !!row_confuse && !!columnClass_confuse, hasFacebook_confuse: text_confuse.includes('有FB') };
    })()`);
    if (!result_confuse?.found_confuse) throw new Error("无法读取后台项目的标签信息。")
    return result_confuse.hasFacebook_confuse === true;
}

/**
 * 打开目标行域名配置弹窗并读取配置域名和网页域名。
 * 参数：debuggee_confuse 为后台页，bundleID_confuse 为目标 Bundle ID。
 * 返回值：包含两个域名的对象。
 * 异常：域名入口、弹窗或任一字段不存在时抛出错误。
 */
async function readBackendDomains_confuse(debuggee_confuse, bundleID_confuse) {
    const bundleJSON_confuse = JSON.stringify(bundleID_confuse);
    await waitForExpression_confuse(
        debuggee_confuse,
        `(() => {
            const row_confuse = Array.from(document.querySelectorAll('.vxe-body--row')).find((item_confuse) =>
                Array.from(item_confuse.querySelectorAll('td')).some((cell_confuse) =>
                    String(cell_confuse.textContent || '').trim() === ${bundleJSON_confuse}
                )
            );
            return !!row_confuse && Array.from(row_confuse.querySelectorAll('td')).some((cell_confuse) =>
                String(cell_confuse.textContent || '').includes('点击查看')
            );
        })()`,
        BACKEND_PAGE_TIMEOUT_SECONDS_CONFUSE,
        "域名配置入口加载超时，请稍后重试。"
    );
    const opened_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const row_confuse = Array.from(document.querySelectorAll('.vxe-body--row')).find((item_confuse) =>
            Array.from(item_confuse.querySelectorAll('td')).some((cell_confuse) =>
                String(cell_confuse.textContent || '').trim() === ${bundleJSON_confuse}
            )
        );
        const header_confuse = Array.from(document.querySelectorAll('th')).find((item_confuse) =>
            String(item_confuse.textContent || '').includes('域名配置')
        );
        const columnClass_confuse = Array.from(header_confuse?.classList || []).find((name_confuse) => name_confuse.startsWith('col_'));
        const cell_confuse = columnClass_confuse ? row_confuse?.querySelector('.' + columnClass_confuse) : null;
        const trigger_confuse = Array.from(cell_confuse?.querySelectorAll('*') || [])
            .filter((item_confuse) => String(item_confuse.textContent || '').includes('点击查看'))
            .sort((left_confuse, right_confuse) =>
                String(left_confuse.textContent || '').length - String(right_confuse.textContent || '').length
            )[0];
        const clickable_confuse = trigger_confuse?.closest('button, a, [role="button"]')
            || trigger_confuse;
        if (!clickable_confuse) return false;
        clickable_confuse.scrollIntoView({ block: 'center', inline: 'center' });
        clickable_confuse.click();
        return true;
    })()`);
    if (!opened_confuse) throw new Error("无法打开目标项目的域名配置。")
    await delay_confuse(BACKEND_DIALOG_SETTLE_DELAY_MILLISECONDS_CONFUSE);
    await waitForExpression_confuse(
        debuggee_confuse,
        "Array.from(document.querySelectorAll('.vxe-modal--wrapper, [role=dialog]')).some((item_confuse) => item_confuse.offsetParent !== null && item_confuse.innerText.includes('配置域名') && item_confuse.innerText.includes('网页域名'))",
        BACKEND_PAGE_TIMEOUT_SECONDS_CONFUSE,
        "域名配置弹窗加载超时。"
    );
    const domains_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const modal_confuse = Array.from(document.querySelectorAll('.vxe-modal--wrapper, [role=dialog]')).find((item_confuse) =>
            item_confuse.offsetParent !== null && item_confuse.innerText.includes('配置域名') && item_confuse.innerText.includes('网页域名')
        );
        const rows_confuse = Array.from(modal_confuse?.querySelectorAll('tr') || []);
        const value_confuse = (names_confuse) => {
            const nameList_confuse = Array.isArray(names_confuse)
                ? names_confuse
                : [names_confuse];
            const row_confuse = rows_confuse.find((item_confuse) => {
                const cellTexts_confuse = Array.from(item_confuse.querySelectorAll('td'))
                    .map((cell_confuse) => String(cell_confuse.textContent || '').trim());
                return nameList_confuse.some((name_confuse) =>
                    cellTexts_confuse.includes(name_confuse)
                ) || nameList_confuse.some((name_confuse) =>
                    String(item_confuse.textContent || '').includes(name_confuse)
                );
            });
            const cells_confuse = Array.from(row_confuse?.querySelectorAll('td') || []);
            const labelIndex_confuse = cells_confuse.findIndex((cell_confuse) =>
                nameList_confuse.includes(String(cell_confuse.textContent || '').trim())
            );
            const candidates_confuse = cells_confuse
                .slice(labelIndex_confuse >= 0 ? labelIndex_confuse + 1 : 0)
                .map((cell_confuse) => String(cell_confuse.textContent || '')
                    .replace('复制', '')
                    .replace('查看', '')
                    .trim())
                .filter((value_confuse) =>
                    value_confuse
                    && value_confuse !== '-'
                    && /^https?:\/\//i.test(value_confuse)
                );
            return candidates_confuse[0] || '';
        };
        return {
            configurationDomain_confuse: value_confuse('配置域名'),
            requestDomain_confuse: value_confuse(['网页域名', '网页地址'])
        };
    })()`);
    await closeBackendDialog_confuse(debuggee_confuse);
    if (!domains_confuse?.configurationDomain_confuse || !domains_confuse?.requestDomain_confuse) {
        throw new Error("域名配置中缺少配置域名或网页域名。")
    }
    return domains_confuse;
}

/**
 * 打开目标行配置弹窗并按 Key 读取 AppsFlyer 与 Facebook 字段。
 * 参数：debuggee_confuse 为后台页，bundleID_confuse 为目标 Bundle ID。
 * 返回值：以后台 Key 为键的配置对象。
 * 异常：配置入口或配置表加载失败时抛出错误。
 */
async function readBackendAppConfiguration_confuse(debuggee_confuse, bundleID_confuse) {
    const bundleJSON_confuse = JSON.stringify(bundleID_confuse);
    await waitForExpression_confuse(
        debuggee_confuse,
        `(() => {
            const row_confuse = Array.from(document.querySelectorAll('.vxe-body--row')).find((item_confuse) =>
                Array.from(item_confuse.querySelectorAll('td')).some((cell_confuse) =>
                    String(cell_confuse.textContent || '').trim() === ${bundleJSON_confuse}
                )
            );
            return !!row_confuse && Array.from(row_confuse.querySelectorAll('button, a, [role="button"]')).some((item_confuse) =>
                String(item_confuse.textContent || '').trim() === '配置'
            );
        })()`,
        BACKEND_PAGE_TIMEOUT_SECONDS_CONFUSE,
        "后台配置入口加载超时，请稍后重试。"
    );
    const opened_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const row_confuse = Array.from(document.querySelectorAll('.vxe-body--row')).find((item_confuse) =>
            Array.from(item_confuse.querySelectorAll('td')).some((cell_confuse) =>
                String(cell_confuse.textContent || '').trim() === ${bundleJSON_confuse}
            )
        );
        const header_confuse = Array.from(document.querySelectorAll('th')).find((item_confuse) =>
            String(item_confuse.textContent || '').trim() === '操作'
        );
        const columnClass_confuse = Array.from(header_confuse?.classList || []).find((name_confuse) => name_confuse.startsWith('col_'));
        const cell_confuse = columnClass_confuse ? row_confuse?.querySelector('.' + columnClass_confuse) : null;
        const button_confuse = Array.from(cell_confuse?.querySelectorAll('button') || []).find((item_confuse) =>
            String(item_confuse.textContent || '').trim() === '配置'
        );
        if (!button_confuse) return false;
        button_confuse.scrollIntoView({ block: 'center', inline: 'center' });
        button_confuse.click();
        return true;
    })()`);
    if (!opened_confuse) throw new Error("无法打开目标项目的配置页面。")
    await delay_confuse(BACKEND_DIALOG_SETTLE_DELAY_MILLISECONDS_CONFUSE);
    await waitForExpression_confuse(
        debuggee_confuse,
        "Array.from(document.querySelectorAll('.vxe-modal--wrapper, [role=dialog]')).some((item_confuse) => item_confuse.offsetParent !== null && item_confuse.innerText.includes('AppsFlyerDevKey'))",
        BACKEND_PAGE_TIMEOUT_SECONDS_CONFUSE,
        "后台配置表加载超时。"
    );
    const configuration_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const modal_confuse = Array.from(document.querySelectorAll('.vxe-modal--wrapper, [role=dialog]')).find((item_confuse) =>
            item_confuse.offsetParent !== null && item_confuse.innerText.includes('AppsFlyerDevKey')
        );
        const wantedKeys_confuse = new Set([
            'AppsFlyerDevKey',
            'AppsFlyerAppId',
            'FacebookAppID',
            'FacebookClientToken',
            'FacebookDisplayName'
        ]);
        const result_confuse = {};
        for (const row_confuse of Array.from(modal_confuse?.querySelectorAll('tr') || [])) {
            const cells_confuse = Array.from(row_confuse.querySelectorAll('td'));
            const key_confuse = String(cells_confuse[0]?.textContent || '').trim();
            if (!wantedKeys_confuse.has(key_confuse)) continue;
            result_confuse[key_confuse] = String(cells_confuse[2]?.textContent || '')
                .replace(/^查看\s*/, '')
                .trim();
        }
        return result_confuse;
    })()`);
    await closeBackendDialog_confuse(debuggee_confuse);
    return configuration_confuse || {};
}

/**
 * 关闭当前可见的后台只读弹窗并等待其消失。
 * 参数：debuggee_confuse 为后台页调试目标。
 * 返回值：Promise<void>。
 * 异常：关闭按钮不存在时直接返回。
 */
async function closeBackendDialog_confuse(debuggee_confuse) {
    await evaluate_confuse(debuggee_confuse, `(() => {
        const visible_confuse = (element_confuse) => !!element_confuse
            && !!(element_confuse.offsetWidth || element_confuse.offsetHeight || element_confuse.getClientRects().length);
        const modals_confuse = Array.from(document.querySelectorAll('.vxe-modal--wrapper, [role=dialog]')).filter(visible_confuse);
        const modal_confuse = modals_confuse[modals_confuse.length - 1];
        const closeButton_confuse = modal_confuse?.querySelector('.vxe-modal--close-btn, button[aria-label="Close"]');
        if (!closeButton_confuse) return false;
        closeButton_confuse.click();
        return true;
    })()`);
    await delay_confuse(250);
}

/** 执行完整的飞书定位、查找、详情打开和字段提取流程。 */
async function runMaterialTask_confuse(task_confuse) {
    const taskID_confuse = task_confuse.task_id_confuse;
    const uiNumber_confuse = String(task_confuse.uiNumber_confuse || "").trim();
    if (!uiNumber_confuse) throw new Error("资料整理请求缺少项目 UI 编号。");

    sendProgress_confuse(taskID_confuse, "Chrome 扩展已连接，正在定位飞书项目表。", 0.20);
    const target_confuse = await acquireTargetTab_confuse();
    try {
        sendProgress_confuse(taskID_confuse, "正在等待飞书登录并加载项目表。", 0.30);
        await waitForProjectTable_confuse(target_confuse.debuggee_confuse);
        await closeExistingDetail_confuse(target_confuse.debuggee_confuse);
        sendProgress_confuse(taskID_confuse, "飞书项目表已加载，正在查找项目。", 0.42);
        await searchProject_confuse(target_confuse.debuggee_confuse, uiNumber_confuse);
        sendProgress_confuse(taskID_confuse, "已找到唯一项目，正在打开记录详情。", 0.68);
        await openSelectedRecord_confuse(target_confuse.debuggee_confuse);
        sendProgress_confuse(taskID_confuse, "正在读取项目提交资料。", 0.86);
        const record_confuse = await extractMaterialRecord_confuse(
            target_confuse.debuggee_confuse,
            uiNumber_confuse
        );
        postNativeMessage_confuse({
            task_id_confuse: taskID_confuse,
            event_confuse: "result",
            state_confuse: "completed",
            message_confuse: "项目资料读取完成。",
            progress_confuse: 1,
            ok_confuse: true,
            record_confuse: record_confuse
        });
    } finally {
        await detachDebugger_confuse(target_confuse.debuggee_confuse);
    }
}

/**
 * 在当前 Chrome 窗口中顺序生成请求的协议。
 * 参数：task_confuse 包含任务编号、应用名称、邮箱和协议类型。
 * 返回值：Promise<void>，结果通过原生消息回传。
 * 异常：请求无效、标签页不可控制或网页流程失败时抛出错误。
 */
async function runAgreementTask_confuse(task_confuse) {
    const taskID_confuse = String(task_confuse.task_id_confuse || "");
    const appName_confuse = String(task_confuse.appName_confuse || "").trim();
    const email_confuse = String(task_confuse.email_confuse || "").trim();
    const requestedTypes_confuse = Array.isArray(task_confuse.agreementTypes_confuse)
        ? task_confuse.agreementTypes_confuse
        : [];
    const agreementTypes_confuse = requestedTypes_confuse.filter(
        (type_confuse) => Object.hasOwn(AGREEMENT_GENERATOR_URLS_CONFUSE, type_confuse)
    );
    if (!taskID_confuse || !appName_confuse || !email_confuse || !agreementTypes_confuse.length) {
        throw new Error("协议请求缺少应用名称、邮箱或协议类型。");
    }

    sendProgress_confuse(taskID_confuse, "浏览器助手已连接，正在准备协议生成标签页。", 0.08);
    const target_confuse = await acquireAgreementTab_confuse();
    const links_confuse = {};
    try {
        for (let index_confuse = 0; index_confuse < agreementTypes_confuse.length; index_confuse += 1) {
            const type_confuse = agreementTypes_confuse[index_confuse];
            const name_confuse = AGREEMENT_NAMES_CONFUSE[type_confuse];
            sendAgreementStage_confuse(
                taskID_confuse,
                type_confuse,
                "running",
                `正在当前 Chrome 中生成${name_confuse}。`
            );
            try {
                const link_confuse = await generateAgreement_confuse(
                    target_confuse.debuggee_confuse,
                    type_confuse,
                    appName_confuse,
                    email_confuse
                );
                links_confuse[type_confuse] = link_confuse;
                sendAgreementStage_confuse(
                    taskID_confuse,
                    type_confuse,
                    "completed",
                    `${name_confuse}链接已生成。`,
                    link_confuse
                );
                sendProgress_confuse(
                    taskID_confuse,
                    `${name_confuse}链接已生成。`,
                    0.12 + ((index_confuse + 1) / agreementTypes_confuse.length) * 0.84
                );
            } catch (error_confuse) {
                const message_confuse = error_confuse.message || `${name_confuse}生成失败。`;
                sendAgreementStage_confuse(
                    taskID_confuse,
                    type_confuse,
                    "failed",
                    message_confuse
                );
                throw error_confuse;
            }
        }
        postNativeMessage_confuse({
            task_id_confuse: taskID_confuse,
            event_confuse: "result",
            state_confuse: "completed",
            message_confuse: "协议链接已全部生成。",
            progress_confuse: 1,
            ok_confuse: true,
            links_confuse: links_confuse
        });
    } finally {
        await detachDebugger_confuse(target_confuse.debuggee_confuse);
    }
}

/**
 * 在当前聚焦的 Chrome 窗口新建普通标签页并附加调试器。
 * 参数：无。
 * 返回值：标签页和调试目标组成的对象。
 * 异常：标签页创建或调试器附加失败时抛出错误。
 */
async function acquireAgreementTab_confuse() {
    const activeTabs_confuse = await queryTabs_confuse({ active: true, lastFocusedWindow: true });
    const activeTab_confuse = activeTabs_confuse[0];
    const properties_confuse = { url: "about:blank", active: true };
    if (activeTab_confuse && typeof activeTab_confuse.windowId === "number") {
        properties_confuse.windowId = activeTab_confuse.windowId;
    }
    const tab_confuse = await createTab_confuse(properties_confuse);
    await waitForTabLoad_confuse(tab_confuse.id, 20, "协议标签页创建超时。");
    const debuggee_confuse = { tabId: tab_confuse.id };
    try {
        await attachDebugger_confuse(debuggee_confuse);
        await sendCommand_confuse(debuggee_confuse, "Page.enable");
        await sendCommand_confuse(debuggee_confuse, "Runtime.enable");
    } catch (error_confuse) {
        throw new Error(
            "无法控制协议标签页，可能有其他扩展正在调试该页面。请关闭页面上的调试提示后重试。"
        );
    }
    await activateTab_confuse(tab_confuse);
    return { tab_confuse: tab_confuse, debuggee_confuse: debuggee_confuse };
}

/**
 * 导航到指定协议生成器并等待页面可操作。
 * 参数：debuggee_confuse 为调试目标，type_confuse 为协议类型。
 * 返回值：Promise<void>。
 * 异常：协议类型无效或页面加载超时时抛出错误。
 */
async function navigateAgreementGenerator_confuse(debuggee_confuse, type_confuse) {
    const url_confuse = AGREEMENT_GENERATOR_URLS_CONFUSE[type_confuse];
    if (!url_confuse) throw new Error("不支持指定的协议类型。");
    await sendCommand_confuse(debuggee_confuse, "Page.navigate", { url: url_confuse });
    await waitForExpression_confuse(
        debuggee_confuse,
        "document.readyState === 'complete' && !!document.body && document.body.innerText.includes('Generator')",
        45,
        "协议生成器页面加载超时，请检查当前 Chrome 的网络连接。"
    );
}

/**
 * 向桌面应用回传单项协议的状态。
 * 参数：任务编号、协议类型、状态、说明和可选链接。
 * 返回值：无。
 * 异常：原生消息连接断开时由发送函数抛出错误。
 */
function sendAgreementStage_confuse(
    taskID_confuse,
    type_confuse,
    state_confuse,
    message_confuse,
    link_confuse = null
) {
    const event_confuse = {
        task_id_confuse: taskID_confuse,
        event_confuse: "stage",
        agreementType_confuse: type_confuse,
        state_confuse: state_confuse,
        message_confuse: message_confuse
    };
    if (link_confuse) event_confuse.link_confuse = link_confuse;
    postNativeMessage_confuse(event_confuse);
}

/**
 * 将首个匹配的复选框或单选框调整到指定状态。
 * 参数：调试目标、CSS 选择器和目标选中状态。
 * 返回值：Promise<void>。
 * 异常：控件不存在或状态无法更新时抛出错误。
 */
async function setAgreementControl_confuse(
    debuggee_confuse,
    selector_confuse,
    checked_confuse = true
) {
    const selectorJSON_confuse = JSON.stringify(selector_confuse);
    const updated_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const element_confuse = document.querySelector(${selectorJSON_confuse});
        if (!element_confuse) return false;
        if (!!element_confuse.checked !== ${Boolean(checked_confuse)}) element_confuse.click();
        return !!element_confuse.checked === ${Boolean(checked_confuse)};
    })()`);
    if (!updated_confuse) throw new Error("协议页面选项结构已变化，请稍后重试。");
}

/**
 * 按匹配顺序选中指定网页控件。
 * 参数：调试目标、CSS 选择器和从零开始的控件索引。
 * 返回值：Promise<void>。
 * 异常：控件不存在或无法选中时抛出错误。
 */
async function setAgreementControlAtIndex_confuse(
    debuggee_confuse,
    selector_confuse,
    index_confuse
) {
    const selectorJSON_confuse = JSON.stringify(selector_confuse);
    const selected_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const elements_confuse = Array.from(document.querySelectorAll(${selectorJSON_confuse}));
        const element_confuse = elements_confuse[${index_confuse}];
        if (!element_confuse) return false;
        if (!element_confuse.checked) element_confuse.click();
        return !!element_confuse.checked;
    })()`);
    if (!selected_confuse) throw new Error("协议页面选项结构已变化，请稍后重试。");
}

/**
 * 向当前可见的协议输入框写入文本并触发页面监听事件。
 * 参数：调试目标、CSS 选择器、输入值和是否仅查找可见元素。
 * 返回值：Promise<void>。
 * 异常：输入框不存在或写入失败时抛出错误。
 */
async function fillAgreementInput_confuse(
    debuggee_confuse,
    selector_confuse,
    value_confuse,
    visibleOnly_confuse = true
) {
    const selectorJSON_confuse = JSON.stringify(selector_confuse);
    const valueJSON_confuse = JSON.stringify(value_confuse);
    const filled_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const candidates_confuse = Array.from(document.querySelectorAll(${selectorJSON_confuse}));
        const element_confuse = candidates_confuse.find((item_confuse) =>
            ${Boolean(visibleOnly_confuse)}
                ? !!(item_confuse.offsetWidth || item_confuse.offsetHeight || item_confuse.getClientRects().length)
                : true
        );
        if (!element_confuse) return false;
        const prototype_confuse = element_confuse instanceof HTMLTextAreaElement
            ? HTMLTextAreaElement.prototype
            : HTMLInputElement.prototype;
        const descriptor_confuse = Object.getOwnPropertyDescriptor(prototype_confuse, 'value');
        if (!descriptor_confuse || !descriptor_confuse.set) return false;
        descriptor_confuse.set.call(element_confuse, ${valueJSON_confuse});
        element_confuse.dispatchEvent(new Event('input', { bubbles: true }));
        element_confuse.dispatchEvent(new Event('change', { bubbles: true }));
        element_confuse.blur();
        return element_confuse.value === ${valueJSON_confuse};
    })()`);
    if (!filled_confuse) throw new Error("协议页面输入框结构已变化，请稍后重试。");
}

/**
 * 点击文字匹配且可用的协议页面按钮。
 * 参数：调试目标和按钮包含的文字。
 * 返回值：Promise<void>。
 * 异常：没有找到可点击按钮时抛出错误。
 */
async function clickAgreementButton_confuse(debuggee_confuse, text_confuse) {
    const textJSON_confuse = JSON.stringify(text_confuse);
    const clicked_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const button_confuse = Array.from(document.querySelectorAll('button')).find((item_confuse) =>
            !!(item_confuse.offsetWidth || item_confuse.offsetHeight || item_confuse.getClientRects().length)
            && String(item_confuse.textContent || '').trim().includes(${textJSON_confuse})
            && !item_confuse.disabled
            && !item_confuse.classList.contains('disabled')
        );
        if (!button_confuse) return false;
        button_confuse.click();
        return true;
    })()`);
    if (!clicked_confuse) throw new Error(`未找到可用的“${text_confuse}”按钮。`);
}

/**
 * 保持国家为美国，并在地区下拉框选择纽约州。
 * 参数：debuggee_confuse 为当前协议页面的调试目标。
 * 返回值：Promise<void>。
 * 异常：默认国家不符、地区输入框或纽约州选项不存在时抛出错误。
 */
async function selectAgreementLocation_confuse(debuggee_confuse) {
    const countryReady_confuse = await evaluate_confuse(
        debuggee_confuse,
        "Array.from(document.querySelectorAll('.v-select')).filter((item_confuse) => item_confuse.offsetParent !== null)[0]?.innerText.includes('United States') === true"
    );
    if (!countryReady_confuse) throw new Error("协议页面默认国家不是美国，无法继续自动选择地区。");
    const inputReady_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const inputs_confuse = Array.from(document.querySelectorAll('input.vs__search'))
            .filter((item_confuse) => item_confuse.offsetParent !== null);
        const input_confuse = inputs_confuse[1];
        if (!input_confuse) return false;
        input_confuse.focus();
        const descriptor_confuse = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value');
        descriptor_confuse.set.call(input_confuse, 'New York');
        input_confuse.dispatchEvent(new Event('input', { bubbles: true }));
        return true;
    })()`);
    if (!inputReady_confuse) throw new Error("无法填写协议地区。");
    await waitForExpression_confuse(
        debuggee_confuse,
        "Array.from(document.querySelectorAll('[role=option]')).some((item_confuse) => item_confuse.offsetParent !== null && item_confuse.textContent.trim() === 'New York')",
        8,
        "纽约州选项加载超时。"
    );
    const selected_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const option_confuse = Array.from(document.querySelectorAll('[role=option]')).find(
            (item_confuse) => item_confuse.offsetParent !== null
                && item_confuse.textContent.trim() === 'New York'
        );
        if (!option_confuse) return false;
        option_confuse.click();
        return true;
    })()`);
    if (!selected_confuse) throw new Error("无法选择纽约州。");
}

/**
 * 填写协议共有信息和指定类型的业务选项，并停留在生成页面。
 * 参数：调试目标、协议类型、应用名称和联系邮箱。
 * 返回值：Promise<void>。
 * 异常：页面步骤或任一必填控件不可用时抛出错误。
 */
async function prepareAgreement_confuse(
    debuggee_confuse,
    type_confuse,
    appName_confuse,
    email_confuse
) {
    await navigateAgreementGenerator_confuse(debuggee_confuse, type_confuse);
    if (type_confuse === "eula") {
        await setAgreementControl_confuse(debuggee_confuse, "#agreement_for_Mobile");
    } else {
        await setAgreementControl_confuse(
            debuggee_confuse,
            "input[name='agreement_for'][value='App']"
        );
    }
    await clickAgreementButton_confuse(debuggee_confuse, "Next Step");
    await waitForExpression_confuse(
        debuggee_confuse,
        "!!Array.from(document.querySelectorAll(\"input[placeholder='My App']\")).find((item_confuse) => item_confuse.offsetParent !== null)",
        12,
        "应用信息页面加载超时。"
    );
    await fillAgreementInput_confuse(debuggee_confuse, "input[placeholder='My App']", appName_confuse);
    await setAgreementControl_confuse(
        debuggee_confuse,
        "input[name='entity_type'][value='Individual']"
    );
    await selectAgreementLocation_confuse(debuggee_confuse);
    await clickAgreementButton_confuse(debuggee_confuse, "Next Step");

    if (type_confuse === "privacy") {
        await waitForExpression_confuse(
            debuggee_confuse,
            "document.body.innerText.includes('What kind of personal information do you collect from users?')",
            12,
            "隐私政策选项页面加载超时。"
        );
        await configurePrivacyAgreement_confuse(debuggee_confuse);
    } else if (type_confuse === "terms") {
        await waitForExpression_confuse(
            debuggee_confuse,
            "document.body.innerText.includes('Can users create accounts?')",
            12,
            "使用条款选项页面加载超时。"
        );
        await configureTermsAgreement_confuse(debuggee_confuse);
    } else {
        await waitForExpression_confuse(
            debuggee_confuse,
            "document.body.innerText.includes('Users are not permitted to:')",
            12,
            "最终用户许可协议选项页面加载超时。"
        );
        await configureEULAAgreement_confuse(debuggee_confuse);
    }

    await setAgreementControl_confuse(
        debuggee_confuse,
        "input[name='company_contact'][value='Email']"
    );
    await waitForExpression_confuse(
        debuggee_confuse,
        "!!Array.from(document.querySelectorAll(\"input[placeholder='office@mycompany.com']\")).find((item_confuse) => item_confuse.offsetParent !== null)",
        5,
        "联系邮箱输入框加载超时。"
    );
    await fillAgreementInput_confuse(
        debuggee_confuse,
        "input[placeholder='office@mycompany.com']",
        email_confuse
    );
    await clickAgreementButton_confuse(debuggee_confuse, "Next Step");
    await waitForExpression_confuse(
        debuggee_confuse,
        "!!Array.from(document.querySelectorAll(\"input.form-control[type='text'][placeholder='']\")).find((item_confuse) => item_confuse.offsetParent !== null)",
        12,
        "协议接收邮箱页面加载超时。"
    );
    await fillAgreementInput_confuse(
        debuggee_confuse,
        "input.form-control[type='text'][placeholder='']",
        email_confuse
    );
    await setAgreementControl_confuse(
        debuggee_confuse,
        "input[name='translations'][value='en']"
    );
}

/**
 * 配置隐私政策的数据范围、服务能力和法规选项。
 * 参数：debuggee_confuse 为当前协议页面的调试目标。
 * 返回值：Promise<void>。
 * 异常：预设选项无法定位时抛出错误。
 */
async function configurePrivacyAgreement_confuse(debuggee_confuse) {
    await setAgreementControl_confuse(
        debuggee_confuse,
        "input[name='types_of_data_collected'][value='Email']"
    );
    await setAgreementControl_confuse(
        debuggee_confuse,
        "input[name='app_types_of_data_collected'][value='Camera']"
    );
    const falseFields_confuse = [
        "service_providers_analytics",
        "service_providers_advertising",
        "service_providers_payments",
        "service_providers_behavioral_remarketing",
        "compliance_ccpa",
        "compliance_gdpr",
        "compliance_caloppa",
        "compliance_coppa"
    ];
    for (const field_confuse of falseFields_confuse) {
        await setAgreementControl_confuse(
            debuggee_confuse,
            `input[name='${field_confuse}'][value='false']`
        );
    }
    await setAgreementControlAtIndex_confuse(
        debuggee_confuse,
        "input[name='service_providers_email_marketing']",
        1
    );
    const providers_confuse = ["Invisible reCAPTCHA", "Google Places", "Mouseflow", "FreshDesk"];
    for (const provider_confuse of providers_confuse) {
        await setAgreementControl_confuse(
            debuggee_confuse,
            `input[name='service_providers_miscellaneous_list'][value='${provider_confuse}']`,
            false
        );
    }
}

/**
 * 将使用条款中的可选业务能力按预设设置为否。
 * 参数：debuggee_confuse 为当前协议页面的调试目标。
 * 返回值：Promise<void>。
 * 异常：预设选项无法定位时抛出错误。
 */
async function configureTermsAgreement_confuse(debuggee_confuse) {
    const falseFields_confuse = [
        "user_accounts",
        "user_content",
        "in_app_purchases",
        "ecommerce",
        "subscriptions",
        "intellectual_property",
        "user_feedback",
        "promotions"
    ];
    for (const field_confuse of falseFields_confuse) {
        await setAgreementControl_confuse(
            debuggee_confuse,
            `input[name='${field_confuse}'][value='false']`
        );
    }
}

/**
 * 跳过许可限制，并将最终用户许可协议中的可选能力设置为否。
 * 参数：debuggee_confuse 为当前协议页面的调试目标。
 * 返回值：Promise<void>。
 * 异常：预设选项无法定位时抛出错误。
 */
async function configureEULAAgreement_confuse(debuggee_confuse) {
    const restrictions_confuse = ["Sell/transmit", "Copy/use", "Modify/decrypt"];
    for (const restriction_confuse of restrictions_confuse) {
        await setAgreementControl_confuse(
            debuggee_confuse,
            `input[name='app_set_license_restrictions'][value='${restriction_confuse}']`,
            false
        );
    }
    const falseFields_confuse = [
        "app_application_store",
        "app_user_generated_content",
        "app_updated_regularly",
        "app_use_suggestions",
        "app_privacy_policy",
        "app_intellectual_property"
    ];
    for (const field_confuse of falseFields_confuse) {
        await setAgreementControl_confuse(
            debuggee_confuse,
            `input[name='${field_confuse}'][value='false']`
        );
    }
}

/**
 * 填写并提交一项协议，读取生成后的公开链接。
 * 参数：调试目标、协议类型、应用名称和联系邮箱。
 * 返回值：Promise<string>，内容为公开协议链接。
 * 异常：提交失败或未返回有效链接时抛出错误。
 */
async function generateAgreement_confuse(
    debuggee_confuse,
    type_confuse,
    appName_confuse,
    email_confuse
) {
    await prepareAgreement_confuse(
        debuggee_confuse,
        type_confuse,
        appName_confuse,
        email_confuse
    );
    await clickAgreementButton_confuse(debuggee_confuse, "Generate");
    const linkExpression_confuse = `(() => {
        const candidates_confuse = [
            window.location.href,
            ...Array.from(document.querySelectorAll('input')).map((item_confuse) => item_confuse.value),
            ...Array.from(document.querySelectorAll('a')).map((item_confuse) => item_confuse.href)
        ];
        return candidates_confuse.find((value_confuse) =>
            typeof value_confuse === 'string'
                && /^https:\\/\\/(www\\.)?freeprivacypolicy\\.com\\/live\\//i.test(value_confuse)
        ) || '';
    })()`;
    const link_confuse = await waitForExpression_confuse(
        debuggee_confuse,
        linkExpression_confuse,
        60,
        "生成完成后没有找到协议链接，请在当前 Chrome 标签页中检查页面。"
    );
    if (!link_confuse) throw new Error("协议生成器没有返回有效链接。");
    return link_confuse;
}

/** 发送任务进度，不包含任何飞书字段值。 */
function sendProgress_confuse(taskID_confuse, message_confuse, progress_confuse) {
    postNativeMessage_confuse({
        task_id_confuse: taskID_confuse,
        event_confuse: "progress",
        state_confuse: "running",
        message_confuse: message_confuse,
        progress_confuse: progress_confuse
    });
}

/** 发送失败事件和最终失败结果。 */
function sendFailure_confuse(taskID_confuse, message_confuse) {
    const errorEvent_confuse = {
        task_id_confuse: taskID_confuse,
        state_confuse: "failed",
        message_confuse: message_confuse,
        progress_confuse: 0,
        ok_confuse: false,
        error_confuse: message_confuse
    };
    try {
        postNativeMessage_confuse({ ...errorEvent_confuse, event_confuse: "error" });
        postNativeMessage_confuse({ ...errorEvent_confuse, event_confuse: "result" });
    } catch (error_confuse) {
        console.error("无法向 App Tools 返回失败结果：", error_confuse);
    }
}

/** 查找当前 Chrome 中的目标飞书标签页，必要时新建标签页并附加调试器。 */
async function acquireTargetTab_confuse() {
    const tabs_confuse = await queryTabs_confuse({ url: "https://xx1ch0v03wd.feishu.cn/wiki/*" });
    const matchingTabs_confuse = tabs_confuse.filter((tab_confuse) =>
        String(tab_confuse.url || "").includes(DOCUMENT_MARKER_CONFUSE)
        && String(tab_confuse.url || "").includes(TABLE_MARKER_CONFUSE)
    );
    for (const tab_confuse of matchingTabs_confuse) {
        try {
            const debuggee_confuse = { tabId: tab_confuse.id };
            await attachDebugger_confuse(debuggee_confuse);
            await activateTab_confuse(tab_confuse);
            return { tab_confuse: tab_confuse, debuggee_confuse: debuggee_confuse };
        } catch (_error_confuse) {
            continue;
        }
    }

    const createdTab_confuse = await createTab_confuse({ url: TARGET_URL_CONFUSE, active: true });
    await waitForTabLoad_confuse(createdTab_confuse.id, 45);
    const debuggee_confuse = { tabId: createdTab_confuse.id };
    try {
        await attachDebugger_confuse(debuggee_confuse);
    } catch (error_confuse) {
        throw new Error(
            "无法控制飞书标签页，可能有其他扩展正在调试该页面。请关闭页面上的调试提示后重试。"
        );
    }
    await activateTab_confuse(createdTab_confuse);
    return { tab_confuse: createdTab_confuse, debuggee_confuse: debuggee_confuse };
}

/** 激活目标标签页及其所在窗口。 */
async function activateTab_confuse(tab_confuse) {
    await updateTab_confuse(tab_confuse.id, { active: true });
    if (typeof tab_confuse.windowId === "number") {
        await updateWindow_confuse(tab_confuse.windowId, { focused: true });
    }
}

/** 等待新建标签页完成基础导航。 */
async function waitForTabLoad_confuse(
    tabID_confuse,
    timeoutSeconds_confuse,
    errorMessage_confuse = "飞书项目表标签页加载超时。"
) {
    const deadline_confuse = Date.now() + timeoutSeconds_confuse * 1000;
    while (Date.now() < deadline_confuse) {
        const tab_confuse = await getTab_confuse(tabID_confuse);
        if (tab_confuse.status === "complete") return;
        await delay_confuse(250);
    }
    throw new Error(errorMessage_confuse);
}

/** 等待目标飞书数据表完成登录和 Canvas 初始化。 */
async function waitForProjectTable_confuse(debuggee_confuse) {
    const deadline_confuse = Date.now() + 180000;
    while (Date.now() < deadline_confuse) {
        const state_confuse = await evaluate_confuse(debuggee_confuse, `(() => ({
            table_confuse: !!document.querySelector('.faster-view canvas'),
            find_confuse: !!document.querySelector('.toolbar-find-wrapper')
        }))()`);
        if (state_confuse && state_confuse.table_confuse && state_confuse.find_confuse) return;
        await delay_confuse(500);
    }
    throw new Error("等待飞书登录或项目表加载超时，请确认当前 Chrome 已登录并能打开目标表格。");
}

/** 关闭上一次残留的飞书详情面板，避免遮挡本次查找。 */
async function closeExistingDetail_confuse(debuggee_confuse) {
    const hasDetail_confuse = await evaluate_confuse(
        debuggee_confuse,
        "!!document.querySelector('#BASE_CARD_MODAL_CONTENT_FOCUS_ID')"
    );
    if (!hasDetail_confuse) return;
    await sendCommand_confuse(debuggee_confuse, "Input.dispatchKeyEvent", {
        type: "rawKeyDown",
        key: "Escape",
        code: "Escape",
        windowsVirtualKeyCode: 27,
        nativeVirtualKeyCode: 53
    });
    await sendCommand_confuse(debuggee_confuse, "Input.dispatchKeyEvent", {
        type: "keyUp",
        key: "Escape",
        code: "Escape",
        windowsVirtualKeyCode: 27,
        nativeVirtualKeyCode: 53
    });
    const deadline_confuse = Date.now() + 5000;
    while (Date.now() < deadline_confuse) {
        const stillOpen_confuse = await evaluate_confuse(
            debuggee_confuse,
            "!!document.querySelector('#BASE_CARD_MODAL_CONTENT_FOCUS_ID')"
        );
        if (!stillOpen_confuse) return;
        await delay_confuse(200);
    }
    throw new Error("无法关闭上一次打开的飞书记录详情，请手动关闭后重试。");
}

/** 打开飞书查找框、写入完整 UI 编号并校验唯一结果。 */
async function searchProject_confuse(debuggee_confuse, uiNumber_confuse) {
    const opened_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const selector_confuse = "input[placeholder='在数据表中查找']";
        if (document.querySelector(selector_confuse)) return true;
        const wrapper_confuse = document.querySelector('.toolbar-find-wrapper');
        if (!wrapper_confuse) return false;
        const trigger_confuse = wrapper_confuse.querySelector('.interactive') || wrapper_confuse;
        trigger_confuse.click();
        return true;
    })()`);
    if (!opened_confuse) throw new Error("无法找到飞书项目查找按钮，请刷新目标表格后重试。");

    await waitForExpression_confuse(
        debuggee_confuse,
        `(() => {
            const input_confuse = document.querySelector("input[placeholder='在数据表中查找']");
            return !!input_confuse && !!(input_confuse.offsetWidth || input_confuse.offsetHeight || input_confuse.getClientRects().length);
        })()`,
        20,
        "飞书项目查找框仍未显示，请刷新目标表格后重试。"
    );

    const uiNumberJSON_confuse = JSON.stringify(uiNumber_confuse);
    const filled_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const input_confuse = document.querySelector("input[placeholder='在数据表中查找']");
        if (!input_confuse) return false;
        input_confuse.focus();
        input_confuse.select();
        const setter_confuse = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
        setter_confuse.call(input_confuse, ${uiNumberJSON_confuse});
        input_confuse.dispatchEvent(new InputEvent('input', {
            bubbles: true,
            inputType: 'insertText',
            data: ${uiNumberJSON_confuse}
        }));
        input_confuse.dispatchEvent(new Event('change', { bubbles: true }));
        return input_confuse.value === ${uiNumberJSON_confuse};
    })()`);
    if (!filled_confuse) throw new Error("无法向飞书项目查找框写入 UI 编号。");

    await sendCommand_confuse(debuggee_confuse, "Input.dispatchKeyEvent", {
        type: "rawKeyDown",
        key: "Enter",
        code: "Enter",
        windowsVirtualKeyCode: 13,
        nativeVirtualKeyCode: 36
    });
    await sendCommand_confuse(debuggee_confuse, "Input.dispatchKeyEvent", {
        type: "keyUp",
        key: "Enter",
        code: "Enter",
        windowsVirtualKeyCode: 13,
        nativeVirtualKeyCode: 36
    });

    await delay_confuse(500);
    const deadline_confuse = Date.now() + 30000;
    let result_confuse = null;
    while (Date.now() < deadline_confuse) {
        result_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
            const input_confuse = document.querySelector("input[placeholder='在数据表中查找']");
            if (!input_confuse) return null;
            const containers_confuse = [
                input_confuse.closest('.bitable-findpanel'),
                document.querySelector('.bitable-toolbar-find')
            ];
            let ancestor_confuse = input_confuse.parentElement;
            for (let index_confuse = 0; ancestor_confuse && index_confuse < 7; index_confuse += 1) {
                containers_confuse.push(ancestor_confuse);
                ancestor_confuse = ancestor_confuse.parentElement;
            }
            for (const container_confuse of containers_confuse.filter(Boolean)) {
                const text_confuse = String(container_confuse.innerText || container_confuse.textContent || '');
                const match_confuse = text_confuse.match(/(\\d+)\\s*[\\/／]\\s*(\\d+)/);
                if (!match_confuse) continue;
                return {
                    value_confuse: input_confuse.value,
                    current_confuse: Number(match_confuse[1]),
                    total_confuse: Number(match_confuse[2])
                };
            }
            return {
                value_confuse: input_confuse.value,
                current_confuse: null,
                total_confuse: null
            };
        })()`);
        if (
            result_confuse
            && result_confuse.value_confuse === uiNumber_confuse
            && result_confuse.total_confuse !== null
        ) break;
        await delay_confuse(300);
    }
    if (!result_confuse || result_confuse.total_confuse === null) {
        throw new Error("飞书已执行查找，但无法读取结果数量，请刷新项目表后重试。");
    }
    const total_confuse = Number(result_confuse.total_confuse || 0);
    if (total_confuse === 0) throw new Error(`没有找到 UI 编号为“${uiNumber_confuse}”的项目。`);
    if (total_confuse > 1) {
        throw new Error(`找到 ${total_confuse} 条匹配记录，请检查 UI 编号是否唯一。`);
    }
    await delay_confuse(500);
}

/** 扫描飞书 Canvas 中的蓝色选中边框并返回页面坐标。 */
async function selectedCellCenter_confuse(debuggee_confuse) {
    const center_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const canvases_confuse = Array.from(document.querySelectorAll('.faster-view canvas'))
            .filter((canvas_confuse) => canvas_confuse.width > 0 && canvas_confuse.height > 0)
            .sort((first_confuse, second_confuse) =>
                second_confuse.width * second_confuse.height - first_confuse.width * first_confuse.height
            );
        for (const canvas_confuse of canvases_confuse) {
            const context_confuse = canvas_confuse.getContext('2d');
            if (!context_confuse) continue;
            let image_confuse;
            try {
                image_confuse = context_confuse.getImageData(0, 0, canvas_confuse.width, canvas_confuse.height);
            } catch (_error_confuse) {
                continue;
            }
            const width_confuse = image_confuse.width;
            const height_confuse = image_confuse.height;
            const data_confuse = image_confuse.data;
            const runs_confuse = [];
            const minimumRun_confuse = Math.max(24, Math.floor(width_confuse * 0.018));
            const isBlue_confuse = (index_confuse) => {
                const red_confuse = data_confuse[index_confuse];
                const green_confuse = data_confuse[index_confuse + 1];
                const blue_confuse = data_confuse[index_confuse + 2];
                return red_confuse < 110 && green_confuse >= 55 && green_confuse <= 165 && blue_confuse > 195;
            };
            for (let y_confuse = 0; y_confuse < height_confuse; y_confuse += 1) {
                let x_confuse = 0;
                while (x_confuse < width_confuse) {
                    let index_confuse = (y_confuse * width_confuse + x_confuse) * 4;
                    if (!isBlue_confuse(index_confuse)) {
                        x_confuse += 1;
                        continue;
                    }
                    const startX_confuse = x_confuse;
                    while (x_confuse < width_confuse) {
                        index_confuse = (y_confuse * width_confuse + x_confuse) * 4;
                        if (!isBlue_confuse(index_confuse)) break;
                        x_confuse += 1;
                    }
                    if (x_confuse - startX_confuse >= minimumRun_confuse) {
                        runs_confuse.push([startX_confuse, x_confuse - 1, y_confuse]);
                    }
                }
            }
            let bestPair_confuse = null;
            let bestScore_confuse = -1;
            const minimumHeight_confuse = Math.max(18, Math.floor(height_confuse * 0.018));
            const maximumHeight_confuse = Math.max(65, Math.floor(height_confuse * 0.075));
            const tolerance_confuse = 7;
            for (let firstIndex_confuse = 0; firstIndex_confuse < runs_confuse.length; firstIndex_confuse += 1) {
                const first_confuse = runs_confuse[firstIndex_confuse];
                for (let secondIndex_confuse = firstIndex_confuse + 1; secondIndex_confuse < runs_confuse.length; secondIndex_confuse += 1) {
                    const second_confuse = runs_confuse[secondIndex_confuse];
                    const distance_confuse = second_confuse[2] - first_confuse[2];
                    if (distance_confuse > maximumHeight_confuse) break;
                    if (distance_confuse < minimumHeight_confuse) continue;
                    if (Math.abs(first_confuse[0] - second_confuse[0]) > tolerance_confuse) continue;
                    if (Math.abs(first_confuse[1] - second_confuse[1]) > tolerance_confuse) continue;
                    const score_confuse = Math.min(
                        first_confuse[1] - first_confuse[0],
                        second_confuse[1] - second_confuse[0]
                    ) - Math.abs(first_confuse[0] - second_confuse[0])
                      - Math.abs(first_confuse[1] - second_confuse[1]);
                    if (score_confuse > bestScore_confuse) {
                        bestScore_confuse = score_confuse;
                        bestPair_confuse = [first_confuse, second_confuse];
                    }
                }
            }
            if (!bestPair_confuse) continue;
            const first_confuse = bestPair_confuse[0];
            const second_confuse = bestPair_confuse[1];
            const rect_confuse = canvas_confuse.getBoundingClientRect();
            return {
                x_confuse: rect_confuse.left
                    + ((first_confuse[0] + first_confuse[1]) / 2) * rect_confuse.width / width_confuse,
                y_confuse: rect_confuse.top
                    + ((first_confuse[2] + second_confuse[2]) / 2) * rect_confuse.height / height_confuse
            };
        }
        return null;
    })()`);
    if (!center_confuse) {
        throw new Error("无法定位飞书查找结果，请确认查找框显示为“1 / 1”后重试。");
    }
    return center_confuse;
}

/** 使用 Chrome 调试接口发送真实右键事件并打开记录详情。 */
async function openSelectedRecord_confuse(debuggee_confuse) {
    const center_confuse = await selectedCellCenter_confuse(debuggee_confuse);
    await sendCommand_confuse(debuggee_confuse, "Input.dispatchMouseEvent", {
        type: "mouseMoved",
        x: center_confuse.x_confuse,
        y: center_confuse.y_confuse
    });
    await sendCommand_confuse(debuggee_confuse, "Input.dispatchMouseEvent", {
        type: "mousePressed",
        x: center_confuse.x_confuse,
        y: center_confuse.y_confuse,
        button: "right",
        buttons: 2,
        clickCount: 1
    });
    await sendCommand_confuse(debuggee_confuse, "Input.dispatchMouseEvent", {
        type: "mouseReleased",
        x: center_confuse.x_confuse,
        y: center_confuse.y_confuse,
        button: "right",
        buttons: 0,
        clickCount: 1
    });
    await waitForExpression_confuse(
        debuggee_confuse,
        "document.body.innerText.includes('查看详情')",
        10,
        "飞书记录右键菜单加载超时，请保持目标标签页可见后重试。"
    );
    const detailMenuCenter_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const normalizeText_confuse = (value_confuse) => String(value_confuse || '')
            .replace(/[\\u200B-\\u200D\\uFEFF]/g, '')
            .trim();
        const primaryCandidates_confuse = Array.from(document.querySelectorAll(
            '.b-menu__item, [role=menuitem], [role=option]'
        ));
        const fallbackCandidates_confuse = Array.from(document.querySelectorAll('li, button, div, span'));
        const candidates_confuse = [...primaryCandidates_confuse, ...fallbackCandidates_confuse];
        const target_confuse = candidates_confuse.find((element_confuse) =>
            normalizeText_confuse(element_confuse.innerText || element_confuse.textContent) === '查看详情'
            && !!(element_confuse.offsetWidth || element_confuse.offsetHeight || element_confuse.getClientRects().length)
        );
        if (!target_confuse) return null;
        const clickable_confuse = target_confuse.closest(
            '.b-menu__item, [role=menuitem], [role=option], li, button'
        ) || target_confuse;
        const rect_confuse = clickable_confuse.getBoundingClientRect();
        if (rect_confuse.width <= 0 || rect_confuse.height <= 0) return null;
        return {
            x_confuse: rect_confuse.left + rect_confuse.width / 2,
            y_confuse: rect_confuse.top + rect_confuse.height / 2
        };
    })()`);
    if (!detailMenuCenter_confuse) throw new Error("无法定位飞书记录的查看详情菜单。");
    await sendCommand_confuse(debuggee_confuse, "Input.dispatchMouseEvent", {
        type: "mouseMoved",
        x: detailMenuCenter_confuse.x_confuse,
        y: detailMenuCenter_confuse.y_confuse
    });
    await sendCommand_confuse(debuggee_confuse, "Input.dispatchMouseEvent", {
        type: "mousePressed",
        x: detailMenuCenter_confuse.x_confuse,
        y: detailMenuCenter_confuse.y_confuse,
        button: "left",
        buttons: 1,
        clickCount: 1
    });
    await sendCommand_confuse(debuggee_confuse, "Input.dispatchMouseEvent", {
        type: "mouseReleased",
        x: detailMenuCenter_confuse.x_confuse,
        y: detailMenuCenter_confuse.y_confuse,
        button: "left",
        buttons: 0,
        clickCount: 1
    });
    await waitForExpression_confuse(
        debuggee_confuse,
        "!!document.querySelector('#BASE_CARD_MODAL_CONTENT_FOCUS_ID label[data-field-id]')",
        15,
        "飞书记录详情加载超时。"
    );
}

/** 从飞书详情面板读取目标字段，并用 UI 编号确认记录一致。 */
async function extractMaterialRecord_confuse(debuggee_confuse, uiNumber_confuse) {
    const fieldsJSON_confuse = JSON.stringify(FIELD_KEYS_CONFUSE);
    const record_confuse = await evaluate_confuse(debuggee_confuse, `(() => {
        const fieldKeys_confuse = ${fieldsJSON_confuse};
        const result_confuse = {};
        for (const key_confuse of Object.values(fieldKeys_confuse)) result_confuse[key_confuse] = '';
        const labels_confuse = Array.from(document.querySelectorAll(
            '#BASE_CARD_MODAL_CONTENT_FOCUS_ID label[data-field-id]'
        ));
        for (const label_confuse of labels_confuse) {
            const lines_confuse = label_confuse.innerText
                .replace(/[\\u200B-\\u200D\\uFEFF]/g, '')
                .split('\\n')
                .map((line_confuse) => line_confuse.trim())
                .filter(Boolean);
            if (!lines_confuse.length) continue;
            const fieldName_confuse = lines_confuse.shift();
            const resultKey_confuse = fieldKeys_confuse[fieldName_confuse];
            if (!resultKey_confuse) continue;
            let value_confuse = lines_confuse.join('\\n');
            if (!value_confuse) {
                const input_confuse = label_confuse.querySelector('input, textarea');
                value_confuse = input_confuse ? String(input_confuse.value || '').trim() : '';
            }
            result_confuse[resultKey_confuse] = value_confuse;
        }
        return result_confuse;
    })()`);
    if (!record_confuse || typeof record_confuse !== "object") {
        throw new Error("飞书详情字段结构已变化，请刷新页面后重试。");
    }
    const recordUINumber_confuse = String(record_confuse.uiNumber_confuse || "").trim();
    if (recordUINumber_confuse !== uiNumber_confuse) {
        throw new Error(
            `查找结果的 UI 编号为“${recordUINumber_confuse || "未填写"}”，请检查编号后重试。`
        );
    }
    return record_confuse;
}

/** 轮询一个页面表达式直到返回真值。 */
async function waitForExpression_confuse(
    debuggee_confuse,
    expression_confuse,
    timeoutSeconds_confuse,
    errorMessage_confuse
) {
    const deadline_confuse = Date.now() + timeoutSeconds_confuse * 1000;
    while (Date.now() < deadline_confuse) {
        try {
            const result_confuse = await evaluate_confuse(debuggee_confuse, expression_confuse);
            if (result_confuse) return result_confuse;
        } catch (_error_confuse) {
            // 页面导航会短暂销毁执行上下文，等待新页面就绪后继续检查。
        }
        await delay_confuse(250);
    }
    throw new Error(errorMessage_confuse);
}

/** 在目标标签页主环境执行 JavaScript，并返回可序列化结果。 */
async function evaluate_confuse(debuggee_confuse, expression_confuse) {
    const response_confuse = await sendCommand_confuse(debuggee_confuse, "Runtime.evaluate", {
        expression: expression_confuse,
        returnByValue: true,
        awaitPromise: true
    });
    if (response_confuse.exceptionDetails) {
        const detail_confuse = response_confuse.exceptionDetails.exception?.description
            || response_confuse.exceptionDetails.text
            || "未知页面错误";
        throw new Error(`浏览器页面执行失败：${detail_confuse}`);
    }
    return response_confuse.result ? response_confuse.result.value : null;
}

/** 附加 Chrome 调试器。 */
function attachDebugger_confuse(debuggee_confuse) {
    return new Promise((resolve_confuse, reject_confuse) => {
        chrome.debugger.attach(debuggee_confuse, "1.3", () => {
            if (chrome.runtime.lastError) {
                reject_confuse(new Error(chrome.runtime.lastError.message));
            } else {
                resolve_confuse();
            }
        });
    });
}

/** 解除 Chrome 调试器；标签页已经关闭时忽略错误。 */
function detachDebugger_confuse(debuggee_confuse) {
    return new Promise((resolve_confuse) => {
        chrome.debugger.detach(debuggee_confuse, () => resolve_confuse());
    });
}

/** 发送一条 Chrome DevTools 命令。 */
function sendCommand_confuse(debuggee_confuse, method_confuse, parameters_confuse = {}) {
    return new Promise((resolve_confuse, reject_confuse) => {
        chrome.debugger.sendCommand(
            debuggee_confuse,
            method_confuse,
            parameters_confuse,
            (response_confuse) => {
                if (chrome.runtime.lastError) {
                    reject_confuse(new Error(chrome.runtime.lastError.message));
                } else {
                    resolve_confuse(response_confuse || {});
                }
            }
        );
    });
}

/** 查询 Chrome 标签页。 */
function queryTabs_confuse(query_confuse) {
    return new Promise((resolve_confuse, reject_confuse) => {
        chrome.tabs.query(query_confuse, (tabs_confuse) => {
            if (chrome.runtime.lastError) reject_confuse(new Error(chrome.runtime.lastError.message));
            else resolve_confuse(tabs_confuse || []);
        });
    });
}

/** 新建 Chrome 标签页。 */
function createTab_confuse(properties_confuse) {
    return new Promise((resolve_confuse, reject_confuse) => {
        chrome.tabs.create(properties_confuse, (tab_confuse) => {
            if (chrome.runtime.lastError) reject_confuse(new Error(chrome.runtime.lastError.message));
            else resolve_confuse(tab_confuse);
        });
    });
}

/** 读取指定 Chrome 标签页。 */
function getTab_confuse(tabID_confuse) {
    return new Promise((resolve_confuse, reject_confuse) => {
        chrome.tabs.get(tabID_confuse, (tab_confuse) => {
            if (chrome.runtime.lastError) reject_confuse(new Error(chrome.runtime.lastError.message));
            else resolve_confuse(tab_confuse);
        });
    });
}

/** 更新指定 Chrome 标签页。 */
function updateTab_confuse(tabID_confuse, properties_confuse) {
    return new Promise((resolve_confuse, reject_confuse) => {
        chrome.tabs.update(tabID_confuse, properties_confuse, (tab_confuse) => {
            if (chrome.runtime.lastError) reject_confuse(new Error(chrome.runtime.lastError.message));
            else resolve_confuse(tab_confuse);
        });
    });
}

/** 更新指定 Chrome 窗口。 */
function updateWindow_confuse(windowID_confuse, properties_confuse) {
    return new Promise((resolve_confuse, reject_confuse) => {
        chrome.windows.update(windowID_confuse, properties_confuse, (window_confuse) => {
            if (chrome.runtime.lastError) reject_confuse(new Error(chrome.runtime.lastError.message));
            else resolve_confuse(window_confuse);
        });
    });
}

/** 等待指定毫秒数。 */
function delay_confuse(milliseconds_confuse) {
    return new Promise((resolve_confuse) => setTimeout(resolve_confuse, milliseconds_confuse));
}

chrome.runtime.onInstalled.addListener(() => connectNativeHost_confuse());
chrome.runtime.onStartup.addListener(() => connectNativeHost_confuse());
chrome.action.onClicked.addListener(() => connectNativeHost_confuse());
connectNativeHost_confuse();

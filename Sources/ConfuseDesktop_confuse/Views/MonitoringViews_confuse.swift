import SwiftUI
import UniformTypeIdentifiers

/// 根据监控审核二级菜单展示状态面板或审核记录，并统一管理表单弹窗。
struct MonitoringContentView_confuse: View {
    @ObservedObject var viewModel_confuse: MonitoringViewModel_confuse
    let menu_confuse: MonitoringAuditMenu_confuse

    /// 返回当前监控审核页面。
    var body: some View {
        Group {
            switch menu_confuse {
            case .status_confuse:
                MonitoringDashboardView_confuse(viewModel_confuse: viewModel_confuse)
            case .records_confuse:
                MonitoringRecordsView_confuse(viewModel_confuse: viewModel_confuse)
            }
        }
        .sheet(isPresented: $viewModel_confuse.isShowingEditor_confuse) {
            MonitoringApplicationEditorView_confuse(viewModel_confuse: viewModel_confuse)
        }
        .sheet(isPresented: $viewModel_confuse.isShowingSettings_confuse) {
            MonitoringSettingsView_confuse(viewModel_confuse: viewModel_confuse)
        }
        .alert(viewModel_confuse.alertTitle_confuse, isPresented: $viewModel_confuse.isShowingAlert_confuse) {
            Button("确定") { viewModel_confuse.dismissAlert_confuse() }
        } message: {
            Text(viewModel_confuse.alertMessage_confuse)
        }
    }
}

/// 展示监控控制、状态统计、筛选工具和全部受管应用。
private struct MonitoringDashboardView_confuse: View {
    @ObservedObject var viewModel_confuse: MonitoringViewModel_confuse

    /// 返回审核状态主面板。
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header_confuse
                metrics_confuse
                toolbar_confuse
                applicationList_confuse
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 30)
        }
    }

    /// 返回页面标题、运行状态与监控操作按钮。
    private var header_confuse: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text("审核状态监控")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("集中查看苹果开发者后台的审核进度和最近巡检结果。")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.52))
                HStack(spacing: 7) {
                    Circle()
                        .fill(viewModel_confuse.isMonitoring_confuse ? Color.confuseAccent_confuse : Color.white.opacity(0.3))
                        .frame(width: 7, height: 7)
                    Text(viewModel_confuse.statusText_confuse)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                }
                .padding(.top, 4)
            }
            Spacer()
            Button {
                viewModel_confuse.checkNow_confuse()
            } label: {
                Label("立即检查", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .disabled(viewModel_confuse.isChecking_confuse)

            Button {
                viewModel_confuse.toggleMonitoring_confuse()
            } label: {
                Label(
                    viewModel_confuse.isMonitoring_confuse ? "停止监控" : "开始监控",
                    systemImage: viewModel_confuse.isMonitoring_confuse ? "stop.fill" : "play.fill"
                )
            }
            .buttonStyle(.borderedProminent)
            .tint(viewModel_confuse.isMonitoring_confuse ? .red.opacity(0.8) : Color.confuseAccent_confuse)
        }
    }

    /// 返回应用总数及关键审核分类统计。
    private var metrics_confuse: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            MonitoringMetricView_confuse(
                title_confuse: "全部应用",
                value_confuse: viewModel_confuse.totalCount_confuse,
                color_confuse: Color.confuseBlue_confuse,
                iconName_confuse: "square.stack.3d.up.fill"
            )
            MonitoringMetricView_confuse(
                title_confuse: "审核流程",
                value_confuse: viewModel_confuse.pipelineCount_confuse,
                color_confuse: .orange,
                iconName_confuse: "clock.fill"
            )
            MonitoringMetricView_confuse(
                title_confuse: "已通过",
                value_confuse: viewModel_confuse.approvedCount_confuse,
                color_confuse: Color.confuseAccent_confuse,
                iconName_confuse: "checkmark.circle.fill"
            )
            MonitoringMetricView_confuse(
                title_confuse: "已拒绝",
                value_confuse: viewModel_confuse.rejectedCount_confuse,
                color_confuse: .red,
                iconName_confuse: "xmark.octagon.fill"
            )
        }
    }

    /// 返回搜索、状态筛选、数据目录、设置和添加应用工具栏。
    private var toolbar_confuse: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.35))
                TextField("搜索应用名称", text: $viewModel_confuse.searchText_confuse)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 11)
            .frame(width: 230, height: 34)
            .background(Color.black.opacity(0.17))
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.confuseBorder_confuse))
            .clipShape(RoundedRectangle(cornerRadius: 7))

            Picker("状态", selection: $viewModel_confuse.selectedCategory_confuse) {
                ForEach(MonitoringStatusCategory_confuse.allCases) { category_confuse in
                    Text(category_confuse.displayName_confuse).tag(category_confuse)
                }
            }
            .frame(width: 155)

            Spacer()

            Button {
                viewModel_confuse.openDataDirectory_confuse()
            } label: {
                Image(systemName: "folder")
            }
            .help("打开数据目录")
            .buttonStyle(.bordered)

            Button {
                viewModel_confuse.presentSettings_confuse()
            } label: {
                Image(systemName: "gearshape")
            }
            .help("监控设置")
            .buttonStyle(.bordered)

            Button {
                viewModel_confuse.presentAddApplication_confuse()
            } label: {
                Label("添加应用", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.confuseBlue_confuse)
        }
    }

    /// 返回应用状态列表或无数据提示。
    @ViewBuilder
    private var applicationList_confuse: some View {
        if viewModel_confuse.filteredApplications_confuse.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "shippingbox")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(Color.confuseAccent_confuse)
                Text(viewModel_confuse.totalCount_confuse == 0 ? "尚无应用" : "没有匹配的应用")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text(viewModel_confuse.totalCount_confuse == 0
                    ? "添加苹果开发者后台凭证后即可开始监控。"
                    : "请调整搜索内容或状态筛选条件。")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.42))
                if viewModel_confuse.totalCount_confuse == 0 {
                    Button("添加应用") { viewModel_confuse.presentAddApplication_confuse() }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.confuseAccent_confuse)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 270)
            .background(Color.confusePanel_confuse)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.confuseBorder_confuse))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            LazyVStack(spacing: 10) {
                ForEach(viewModel_confuse.filteredApplications_confuse) { application_confuse in
                    MonitoringApplicationRow_confuse(
                        viewModel_confuse: viewModel_confuse,
                        application_confuse: application_confuse
                    )
                }
            }
        }
    }
}

/// 展示单个监控应用的状态、凭证标识和快捷操作。
private struct MonitoringApplicationRow_confuse: View {
    @ObservedObject var viewModel_confuse: MonitoringViewModel_confuse
    let application_confuse: MonitoringApplication_confuse

    /// 返回应用状态行。
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(statusColor_confuse.opacity(0.14))
                Image(systemName: statusIcon_confuse)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(statusColor_confuse)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 5) {
                Text(application_confuse.name_confuse.isEmpty ? "应用 \(application_confuse.appID_confuse)" : application_confuse.name_confuse)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("应用编号 \(application_confuse.appID_confuse)  |  版本 \(application_confuse.version_confuse.isEmpty ? "-" : application_confuse.version_confuse)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.38))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 5) {
                Text(application_confuse.label_confuse)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(statusColor_confuse)
                Text(application_confuse.checkedAt_confuse.isEmpty ? "尚未检查" : application_confuse.checkedAt_confuse)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.34))
            }
            .frame(width: 170, alignment: .trailing)

            Toggle("", isOn: Binding(
                get: { application_confuse.isEnabled_confuse },
                set: { isEnabled_confuse in
                    viewModel_confuse.setApplicationEnabled_confuse(
                        application_confuse: application_confuse,
                        isEnabled_confuse: isEnabled_confuse
                    )
                }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .controlSize(.small)
            .help("启用监控")

            Button {
                viewModel_confuse.checkApplication_confuse(application_confuse: application_confuse)
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .help("检查应用")
            .buttonStyle(.plain)
            .disabled(viewModel_confuse.isChecking_confuse)

            Button {
                viewModel_confuse.presentEditApplication_confuse(application_confuse: application_confuse)
            } label: {
                Image(systemName: "pencil")
            }
            .help("编辑应用")
            .buttonStyle(.plain)

            Button {
                viewModel_confuse.removeApplication_confuse(application_confuse: application_confuse)
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red.opacity(0.75))
            }
            .help("移除应用")
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 72)
        .background(Color.confusePanel_confuse)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.confuseBorder_confuse))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    /// 返回当前审核分类对应的颜色。
    private var statusColor_confuse: Color {
        switch application_confuse.category_confuse {
        case .all_confuse, .custom_confuse: return .white.opacity(0.55)
        case .pipeline_confuse: return .orange
        case .approved_confuse: return Color.confuseAccent_confuse
        case .rejected_confuse: return .red
        case .delisted_confuse: return .gray
        }
    }

    /// 返回当前审核分类对应的图标。
    private var statusIcon_confuse: String {
        switch application_confuse.category_confuse {
        case .all_confuse, .custom_confuse: return "questionmark"
        case .pipeline_confuse: return "clock"
        case .approved_confuse: return "checkmark"
        case .rejected_confuse: return "xmark"
        case .delisted_confuse: return "minus"
        }
    }
}

/// 展示监控统计卡片，保持固定高度避免动态数字引起布局跳动。
private struct MonitoringMetricView_confuse: View {
    let title_confuse: String
    let value_confuse: Int
    let color_confuse: Color
    let iconName_confuse: String

    /// 返回统计卡片。
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName_confuse)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color_confuse)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(String(value_confuse))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(title_confuse)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.42))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .frame(height: 70)
        .background(Color.confusePanel_confuse)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.confuseBorder_confuse))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// 展示全部审核查询、状态变化和错误记录。
private struct MonitoringRecordsView_confuse: View {
    @ObservedObject var viewModel_confuse: MonitoringViewModel_confuse

    /// 返回审核记录页面。
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("审核记录")
                        .font(.system(size: 27, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("仅保存审核状态查询结果，不记录私钥内容。")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.52))
                }
                Spacer()
                Button {
                    viewModel_confuse.openDataDirectory_confuse()
                } label: {
                    Label("打开数据目录", systemImage: "folder")
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.35))
                TextField("搜索审核记录", text: $viewModel_confuse.recordSearchText_confuse)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 11)
            .frame(width: 260, height: 34)
            .background(Color.black.opacity(0.17))
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.confuseBorder_confuse))
            .clipShape(RoundedRectangle(cornerRadius: 7))

            if viewModel_confuse.filteredRecords_confuse.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(Color.confuseAccent_confuse)
                    Text("暂无审核记录")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("检查结果和状态变化会显示在这里。")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.42))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.confusePanel_confuse)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.confuseBorder_confuse))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                VStack(spacing: 0) {
                    recordHeader_confuse
                    Divider().overlay(Color.confuseBorder_confuse)
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel_confuse.filteredRecords_confuse) { record_confuse in
                                MonitoringRecordRow_confuse(record_confuse: record_confuse)
                                Divider().overlay(Color.confuseBorder_confuse)
                            }
                        }
                    }
                }
                .background(Color.confusePanel_confuse)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.confuseBorder_confuse))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 30)
    }

    /// 返回审核记录表头。
    private var recordHeader_confuse: some View {
        HStack(spacing: 14) {
            Text("时间").frame(width: 145, alignment: .leading)
            Text("应用").frame(width: 150, alignment: .leading)
            Text("事件").frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(.white.opacity(0.38))
        .padding(.horizontal, 16)
        .frame(height: 38)
    }
}

/// 展示一条审核历史记录。
private struct MonitoringRecordRow_confuse: View {
    let record_confuse: MonitoringRecord_confuse

    /// 返回记录表格行。
    var body: some View {
        HStack(spacing: 14) {
            Text(record_confuse.timestamp_confuse)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.white.opacity(0.42))
                .frame(width: 145, alignment: .leading)
            VStack(alignment: .leading, spacing: 3) {
                Text(record_confuse.applicationName_confuse)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.82))
                    .lineLimit(1)
                Text(record_confuse.appID_confuse)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .frame(width: 150, alignment: .leading)
            HStack(spacing: 8) {
                Circle()
                    .fill(record_confuse.isError_confuse ? Color.red : Color.confuseAccent_confuse)
                    .frame(width: 6, height: 6)
                Text(record_confuse.event_confuse)
                    .font(.system(size: 11))
                    .foregroundStyle(record_confuse.isError_confuse ? Color.red.opacity(0.8) : .white.opacity(0.62))
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 54)
    }
}

/// 提供添加或编辑 App Store Connect 应用凭证的表单。
private struct MonitoringApplicationEditorView_confuse: View {
    @ObservedObject var viewModel_confuse: MonitoringViewModel_confuse
    @State private var isDropTargeted_confuse = false

    /// 返回应用凭证编辑表单。
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("应用监控凭证")
                    .font(.system(size: 21, weight: .bold))
                Text("私钥会复制到应用数据目录，并设置为仅当前用户可读写。")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 14) {
                GridRow {
                    Text("应用编号")
                    TextField("数字应用编号", text: $viewModel_confuse.editor_confuse.appID_confuse)
                }
                GridRow {
                    Text("发行者编号")
                    TextField("发行者编号", text: $viewModel_confuse.editor_confuse.issuerID_confuse)
                }
                GridRow {
                    Text("密钥编号")
                    TextField("密钥编号", text: $viewModel_confuse.editor_confuse.keyID_confuse)
                }
                GridRow {
                    Text("私钥文件")
                    HStack(spacing: 8) {
                        TextField("请选择私钥文件", text: $viewModel_confuse.editor_confuse.privateKeyPath_confuse)
                            .disabled(true)
                        Button("选择") { viewModel_confuse.choosePrivateKey_confuse() }
                    }
                }
            }
            .font(.system(size: 12))

            HStack(spacing: 12) {
                Button {
                    viewModel_confuse.chooseProfileFolder_confuse()
                } label: {
                    Label("读取资料文件夹", systemImage: "folder.badge.plus")
                }
                .buttonStyle(.bordered)
                Text(viewModel_confuse.editor_confuse.importedProfileName_confuse.isEmpty
                    ? "也可以将同时包含资料文件和私钥的文件夹拖入窗口。"
                    : "已读取 \(viewModel_confuse.editor_confuse.importedProfileName_confuse)")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Toggle("启用监控", isOn: $viewModel_confuse.editor_confuse.isEnabled_confuse)
                .toggleStyle(.switch)

            Spacer()

            HStack {
                Spacer()
                Button("取消") { viewModel_confuse.isShowingEditor_confuse = false }
                    .keyboardShortcut(.cancelAction)
                Button("保存") { viewModel_confuse.saveApplication_confuse() }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.confuseAccent_confuse)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 570, height: 410)
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isDropTargeted_confuse) { providers_confuse in
            guard let provider_confuse = providers_confuse.first else { return false }
            provider_confuse.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item_confuse, _ in
                guard let data_confuse = item_confuse as? Data,
                      let url_confuse = URL(dataRepresentation: data_confuse, relativeTo: nil) else { return }
                Task { @MainActor in
                    viewModel_confuse.importProfileFolder_confuse(folderURL_confuse: url_confuse)
                }
            }
            return true
        }
        .overlay {
            if isDropTargeted_confuse {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.confuseAccent_confuse, lineWidth: 2)
                    .padding(5)
                    .allowsHitTesting(false)
            }
        }
    }
}

/// 提供审核监控的代理、通知渠道和轮询间隔设置。
private struct MonitoringSettingsView_confuse: View {
    @ObservedObject var viewModel_confuse: MonitoringViewModel_confuse

    /// 返回监控设置表单。
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("监控设置")
                    .font(.system(size: 21, weight: .bold))
                Text("配置苹果接口访问方式、通知渠道和巡检间隔。")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 14) {
                GridRow {
                    Text("代理地址")
                    TextField("http://127.0.0.1:7897 或 socks5://127.0.0.1:7897", text: $viewModel_confuse.settingsDraft_confuse.proxy_confuse)
                }
                GridRow {
                    Text("消息推送令牌")
                    SecureField("可选", text: $viewModel_confuse.settingsDraft_confuse.pushPlusToken_confuse)
                }
                GridRow {
                    Text("飞书回调地址")
                    SecureField("可选", text: $viewModel_confuse.settingsDraft_confuse.feishuWebhook_confuse)
                }
                GridRow {
                    Text("普通状态间隔")
                    intervalStepper_confuse(value_confuse: $viewModel_confuse.settingsDraft_confuse.defaultInterval_confuse)
                }
                GridRow {
                    Text("审核中间隔")
                    intervalStepper_confuse(value_confuse: $viewModel_confuse.settingsDraft_confuse.reviewInterval_confuse)
                }
                GridRow {
                    Text("已过审间隔")
                    intervalStepper_confuse(value_confuse: $viewModel_confuse.settingsDraft_confuse.approvedInterval_confuse)
                }
            }
            .font(.system(size: 12))

            Toggle("严格代理：苹果接口请求必须使用已配置的代理", isOn: $viewModel_confuse.settingsDraft_confuse.isStrictProxy_confuse)
                .toggleStyle(.switch)

            HStack(spacing: 8) {
                Image(systemName: "externaldrive")
                    .foregroundStyle(Color.confuseBlue_confuse)
                Text(MonitoringStorage_confuse.dataDirectoryURL_confuse().path)
                    .font(.system(size: 10, design: .monospaced))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Button("打开") { viewModel_confuse.openDataDirectory_confuse() }
            }
            .padding(10)
            .background(Color.black.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 7))

            Spacer()

            HStack {
                Spacer()
                Button("取消") { viewModel_confuse.isShowingSettings_confuse = false }
                    .keyboardShortcut(.cancelAction)
                Button("保存") { viewModel_confuse.saveSettings_confuse() }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.confuseAccent_confuse)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 620, height: 480)
    }

    /// 返回以分钟展示、以秒保存的轮询间隔步进器。
    /// - Parameter value_confuse: 秒数绑定。
    /// - Returns: 最小一分钟的步进器。
    private func intervalStepper_confuse(value_confuse: Binding<Int>) -> some View {
        Stepper(value: value_confuse, in: 60...604800, step: 60) {
            Text("\(max(1, value_confuse.wrappedValue / 60)) 分钟")
                .font(.system(size: 11, design: .monospaced))
        }
    }
}

import SwiftUI

/// 展示应用外观设置，将用户操作转交给 AppSettingsViewModel_confuse 并实时预览主题和桌宠。
struct AppSettingsView_confuse: View {
    @ObservedObject var viewModel_confuse: AppSettingsViewModel_confuse

    /// 返回主题颜色与动态桌宠设置页面。
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header_confuse
                themeSection_confuse
                petSection_confuse
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 30)
        }
    }

    /// 返回设置页面标题与恢复按钮。
    private var header_confuse: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 7) {
                Text("设置")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("调整应用主题与侧边栏动态桌宠。")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.52))
            }
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.24)) {
                    viewModel_confuse.restoreDefaults_confuse()
                }
            } label: {
                Label("恢复默认", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 11, weight: .semibold))
            }
            .buttonStyle(.bordered)
        }
    }

    /// 返回主题模式、颜色选择、预设方案和实时预览区域。
    private var themeSection_confuse: some View {
        VStack(alignment: .leading, spacing: 18) {
            SettingsSectionHeader_confuse(
                title_confuse: "主题颜色",
                subtitle_confuse: "选择单色或混色，修改后立即应用到整个工作台。",
                iconName_confuse: "paintpalette.fill"
            )

            HStack(alignment: .top, spacing: 22) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("颜色模式")
                            .settingsFieldLabel_confuse()
                        Picker("颜色模式", selection: $viewModel_confuse.themeMode_confuse) {
                            ForEach(ThemeColorMode_confuse.allCases) { mode_confuse in
                                Text(mode_confuse.displayName_confuse).tag(mode_confuse)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    HStack(spacing: 12) {
                        ColorPicker(
                            "主色",
                            selection: Binding(
                                get: { viewModel_confuse.primaryColor_confuse },
                                set: { viewModel_confuse.updatePrimaryColor_confuse(color_confuse: $0) }
                            ),
                            supportsOpacity: false
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if viewModel_confuse.themeMode_confuse == .blended_confuse {
                            ColorPicker(
                                "辅助色",
                                selection: Binding(
                                    get: { viewModel_confuse.secondaryColor_confuse },
                                    set: { viewModel_confuse.updateSecondaryColor_confuse(color_confuse: $0) }
                                ),
                                supportsOpacity: false
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                        }
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.76))

                    VStack(alignment: .leading, spacing: 9) {
                        Text("预设方案")
                            .settingsFieldLabel_confuse()
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 118), spacing: 8)],
                            spacing: 8
                        ) {
                            ForEach(LocalData_confuse.themePresets_confuse) { preset_confuse in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.22)) {
                                        viewModel_confuse.applyPreset_confuse(preset_confuse: preset_confuse)
                                    }
                                } label: {
                                    HStack(spacing: 9) {
                                        HStack(spacing: 0) {
                                            Color(hex_confuse: preset_confuse.primaryHex_confuse)
                                            Color(hex_confuse: preset_confuse.secondaryHex_confuse)
                                        }
                                        .frame(width: 30, height: 18)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                        Text(preset_confuse.name_confuse)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.76))
                                        Spacer(minLength: 0)
                                    }
                                    .padding(.horizontal, 9)
                                    .frame(height: 34)
                                    .background(Color.black.opacity(0.16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.confuseBorder_confuse, lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)

                ThemePreview_confuse(viewModel_confuse: viewModel_confuse)
                    .frame(width: 248)
            }
        }
        .settingsCard_confuse()
        .animation(.easeInOut(duration: 0.2), value: viewModel_confuse.themeMode_confuse)
    }

    /// 返回轨道探针开关和动态预览区域。
    private var petSection_confuse: some View {
        VStack(alignment: .leading, spacing: 17) {
            SettingsSectionHeader_confuse(
                title_confuse: "动态桌宠",
                subtitle_confuse: "轨道探针会显示在侧边栏底部，并跟随当前主题颜色。",
                iconName_confuse: "sparkles"
            )

            HStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle(
                        "显示轨道探针",
                        isOn: Binding(
                            get: { viewModel_confuse.sidebarPet_confuse == .orbitProbe_confuse },
                            set: { viewModel_confuse.setSidebarPetEnabled_confuse(isEnabled_confuse: $0) }
                        )
                    )
                    .toggleStyle(.switch)
                    .tint(Color.confuseAccent_confuse)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)

                    Text("关闭后侧边栏底部保持留白，设置会在下次启动时继续生效。")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.42))
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.18))
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.confuseBorder_confuse, lineWidth: 1)
                    if viewModel_confuse.sidebarPet_confuse == .orbitProbe_confuse {
                        OrbitProbePetView_confuse()
                            .padding(.horizontal, 12)
                            .transition(.opacity.combined(with: .scale(scale: 0.92)))
                    } else {
                        Image(systemName: "eye.slash")
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(.white.opacity(0.2))
                    }
                }
                .frame(width: 218, height: 126)
                .animation(.easeInOut(duration: 0.24), value: viewModel_confuse.sidebarPet_confuse)
            }
        }
        .settingsCard_confuse()
    }
}

/// 展示设置分组的图标、标题和说明，统一页面信息层级。
private struct SettingsSectionHeader_confuse: View {
    let title_confuse: String
    let subtitle_confuse: String
    let iconName_confuse: String

    /// 返回设置分组标题视图。
    var body: some View {
        HStack(spacing: 11) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.confuseAccent_confuse.opacity(0.12))
                Image(systemName: iconName_confuse)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.confuseAccent_confuse)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 3) {
                Text(title_confuse)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Text(subtitle_confuse)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.42))
            }
        }
    }
}

/// 展示当前主题在按钮、强调线和侧边区域中的组合效果。
private struct ThemePreview_confuse: View {
    @ObservedObject var viewModel_confuse: AppSettingsViewModel_confuse

    /// 返回主题实时预览。
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("实时预览")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.42))

            HStack(spacing: 0) {
                viewModel_confuse.primaryColor_confuse
                viewModel_confuse.secondaryColor_confuse
            }
            .frame(height: 5)
            .clipShape(Capsule())

            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(viewModel_confuse.primaryColor_confuse.opacity(0.16))
                    Image(systemName: "wand.and.stars")
                        .foregroundStyle(viewModel_confuse.primaryColor_confuse)
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 5) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.74))
                        .frame(width: 82, height: 6)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 116, height: 5)
                }
            }

            HStack(spacing: 8) {
                Circle()
                    .fill(viewModel_confuse.secondaryColor_confuse)
                    .frame(width: 7, height: 7)
                Text(viewModel_confuse.themeMode_confuse.displayName_confuse)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
                Spacer()
                Text("主要操作")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.75))
                    .padding(.horizontal, 10)
                    .frame(height: 26)
                    .background(viewModel_confuse.primaryColor_confuse)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, minHeight: 166, alignment: .topLeading)
        .background(Color.black.opacity(0.18))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.confuseBorder_confuse, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// 为设置页面卡片统一提供背景、边框和内边距。
private struct SettingsCardStyle_confuse: ViewModifier {
    /// 应用设置卡片样式。
    /// - Parameter content_confuse: 被修饰的页面内容。
    /// - Returns: 具有统一设置页样式的内容。
    func body(content content_confuse: Content) -> some View {
        content_confuse
            .padding(18)
            .background(Color.confusePanel_confuse)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.confuseBorder_confuse, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// 为设置页面视图提供局部通用样式。
private extension View {
    /// 应用设置卡片样式。
    /// - Returns: 添加卡片背景和边框后的视图。
    func settingsCard_confuse() -> some View {
        modifier(SettingsCardStyle_confuse())
    }

    /// 应用设置字段标题样式。
    /// - Returns: 使用统一字号与透明度的文本视图。
    func settingsFieldLabel_confuse() -> some View {
        font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.white.opacity(0.52))
    }
}

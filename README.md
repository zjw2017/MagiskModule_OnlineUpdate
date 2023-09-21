# Magisk模块在线更新模板

这是一个`适配 Magisk的versionCode大于等于24000`的模块在线更新(updateJson)**模板**

<div align="center">
<strong>
<samp>

[简体中文](README.md) · [English](README_English.md)(English暂未上线)

</samp>
</strong>
</div>

## **使用方法**

### **一、了解相关文件**

| 文件 | 类型 | 功能 |
| :--------:  | :-----:  | :----:  |
| .github/workflows/release.yml | 文件 | 工作流文件|
| module_files | 文件夹 | 存放您模块的相关文件 |
| module.json | 文件 | Magisk检测模块更新的依赖文件 |
| module.md | 文件 | Magisk模块检测到更新，点击<br>更新后，将会弹出更新日志 |

### **二、适配您的模块**

1. **复制文件**：将您的**模块文件夹**复制到**仓库根目录**，像案例中module_files文件夹一样。如果您有您的想法，请遵循您的想法
2. **修改[.github/workflows/release.yml](https://github.com/zjw2017/MagiskModule_OnlineUpdate/blob/main/.github/workflows/release.yml)**：根据**注释**修改相关代码

```yaml
# 本仓库的模块文件名为module_files，下文的url已写入相关文件，可供参考
# 下文所有"- name:"的后面的文案均为步骤名，可自行修改
    # release为工作流名，可自行修改
name: release
on:
  push:
    # 根据以下链接定制您的触发条件
    # https://docs.github.com/zh/actions/using-workflows/triggering-a-workflow
    # https://docs.github.com/zh/actions/using-workflows/events-that-trigger-workflows
    # https://docs.github.com/zh/actions/managing-workflow-runs/skipping-workflow-runs
    branches:
      - main
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@main
      - name: 1. 准备文件
        run: |
          echo "version=$(jq -r .version $GITHUB_WORKSPACE/module.json)" >> $GITHUB_ENV
          echo "versionCode=$(jq -r .versionCode $GITHUB_WORKSPACE/module.json)" >> $GITHUB_ENV
        # ModuleFolderName的变量值需要修改为您模块文件夹的名字
          echo "ModuleFolderName=module_files" >> $GITHUB_ENV
        # 此处可根据您的需求添加您需要的shell语句
      - name: 2. 制作模块
        run: |
          mkdir -p "$GITHUB_WORKSPACE"/GithubRelease
          echo "version=${{ env.version }}" >>$GITHUB_WORKSPACE/${{ env.ModuleFolderName }}/module.prop
          echo "versionCode=${{ env.versionCode }}" >>$GITHUB_WORKSPACE/${{ env.ModuleFolderName }}/module.prop
          cd $GITHUB_WORKSPACE/${{ env.ModuleFolderName }}
          zip -q -r ${{ env.ModuleFolderName }}.zip *
          mv $GITHUB_WORKSPACE/${{ env.ModuleFolderName }}/${{ env.ModuleFolderName }}.zip "$GITHUB_WORKSPACE"/GithubRelease/${{ env.ModuleFolderName }}.zip
          cd "$GITHUB_WORKSPACE"
          touch file.log
          echo "${{ env.ModuleFolderName }}.zip" > file.log
      - name: 3.上传到Github Release
        uses: ncipollo/release-action@main
        with:
          artifacts: ${{ github.workspace }}/GithubRelease/*
          name: "${{ env.ModuleFolderName }} ${{ env.version }}"
        # name后面的是Github Release的标题，可自行修改
        # tag若涉及version和versionCode，请按照${{ env.version }}这个格式来写
          tag: "${{ env.version }}"
          bodyFile: "${{ github.workspace }}/file.log"
          allowUpdates: true
          artifactErrorsFailBuild: true
          makeLatest: true
      - name: 4. 再次初始化仓库
        run: |
          rm -rf $GITHUB_WORKSPACE/*
      - uses: actions/checkout@main
      - name: 5. 更新下载链接
        run: |
        # 请在引号内自行更新您的Github账号信息
          git config --global user.email "30484319+zjw2017@users.noreply.github.com"
        # 请在引号内自行更新您的Github账号信息
          git config --global user.name "柚稚的孩纸"
          sed -i '4d' $GITHUB_WORKSPACE/module.json
        # OWNER、REPO、version分别是用户名、仓库名、版本号，根据自身来修改
          browser_download_url=$(curl -L   -H "Accept: application/vnd.github+json"   -H "Authorization: Bearer ${{ github.token }}"   -H "X-GitHub-Api-Version: 2022-11-28"   https://api.github.com/repos/OWNER/REPO/releases/tags/${{ env.version }} | jq -r .assets[].browser_download_url | cut -d'"' -f2)
        # 作用是自动更新下载地址，因中国大陆地区问题，添加了代理头(https://ghproxy.com/)
        # 如您的地区可以访问Github相关网站，可以删掉代理头，如
        # sed -i '3a "zipUrl": "'"$browser_download_url"'",' $GITHUB_WORKSPACE/module.json
          sed -i '3a "zipUrl": "https://ghproxy.com/'"$browser_download_url"'",' $GITHUB_WORKSPACE/module.json
          jq . $GITHUB_WORKSPACE/module.json > $GITHUB_WORKSPACE/new.json
          rm -rf $GITHUB_WORKSPACE/module.json && mv $GITHUB_WORKSPACE/new.json $GITHUB_WORKSPACE/module.json
          git add ./module.json
        # 引号内为提交信息，可根据需要自行修改。若涉及version和versionCode，请按照${{ env.version }}这个格式来写
          if git commit -m "v${{ env.version }}"; then
              echo "push=true" >> $GITHUB_ENV
          else
              echo "push=false" >> $GITHUB_ENV
          fi
      - name: 6. 更新 .gitattributes
        run: |
        # 请在引号内自行更新您的Github账号信息
          git config --global user.email "30484319+zjw2017@users.noreply.github.com"
        # 请在引号内自行更新您的Github账号信息
          git config --global user.name "柚稚的孩纸"
          sed -i 's/module_files/${{ env.ModuleFolderName }}/g' $GITHUB_WORKSPACE/.gitattributes
          git add ./.gitattributes
          if git commit -m "更新 .gitattributes"; then
              echo "更新 .gitattributes : Success!"
          fi
      - if: ${{ env.push == 'true' }}
        name: 7. 推送到Magisk Module仓库
        uses: ad-m/github-push-action@master
        with:
          branch: ${{ github.ref }}
```

3. **修改[module.md](https://github.com/zjw2017/MagiskModule_OnlineUpdate/blob/main/module.md)**：文件名可**自定义修改**。模块的**更新日志**，语法为`Markdown`
4. **修改[module.json](https://github.com/zjw2017/MagiskModule_OnlineUpdate/blob/main/module.json)**：**文件名**需要**与`.github/workflows/release.yml`中第5行文件名一致**。我们需要修改第**2、3、5**行。

   变量：类型
   - version：string
   - versionCode：int
   - changelog：url
> 补充说明：url为`module.md`的[链接](https://github.com/zjw2017/MagiskModule_OnlineUpdate/blob/main/module.md)，只需要填写一次即可。如果是中国大陆地区，可在上一步中文件的链接前面加代理头（比如[https://ghproxy.com](https://ghproxy.com/)）。如您的地区可以访问Github相关网站，可以删掉代理头

5. **修改模块的`module.prop`以支持在线更新**：格式如下。参数顺序可以打乱，但
   
   **updateJson行**下面的**空行**务必**不能删除**

```text
id=<string>
name=<string>
author=<string>
description=<string>
updateJson=<url>

```

> 补充说明：url为`module.json`的[链接](https://github.com/zjw2017/MagiskModule_OnlineUpdate/blob/main/module.json)，只需要填写一次即可。如果是中国大陆地区，可在上一步中文件的链接前面加代理头（比如[https://ghproxy.com](https://ghproxy.com/)）。如您的地区可以访问Github相关网站，可以删掉代理头

6. 替换模块文件夹中的META-INF

> 原因是**支持在线更新的模块的META-INF会在刷入时被Magisk替换为默认的update-binary**，所以请**不要自定义/META-INF/com/google/android/update-binary文件**。若您**没有修改**过此文件，此步骤**可跳过**

7. 发起Action构建，完成发布


### 三、了解项目机制
本项目利用了**Github Actions**，设计了两种触发方式：**更新.json文件**和**手动触发**。

当您完成代码提交和模块迭代后，就要在 **.json文件** 中配置**版本号**来告知您的用户有新版本，同时，您可以在 **.md文件** 中使用`Markdown`语法书写此次的**更新日志**。不同于系统更新，日志不会叠加。所以您的用户只会看到最新版本的更新日志（除非您更新时保留上次的日志）。

到此，模块的迭代、版本号的更替、更新日志的书写都已经完成，接下来的一切交给**Github Actions**。

**Github Actions**做第一步就是读取 **.json文件** 中的**版本号**信息，将其输出到`module.prop`，这也是为什么前文的`module.prop`中为什么**updateJson行下面的空行不能删除**和**不需要书写版本号**的奥秘。第二步，将模块文件压缩为**zip格式**。第三步，将**模块文件上传**至**Github Release**。第四步，**更新.json文件**中的**下载地址**，并根据**预留的Github账户信息**将含有**新版本链接**的.json**文件**推送到**您的仓库**。

做完了这些，您的用户就可以在**Magisk**的**模块**选项卡中检测到新版本并安装到设备上。

### 四、结语
欢迎大家用来适配自己的模块，同时也期待能有专业人员共同改进本项目，感谢大家！

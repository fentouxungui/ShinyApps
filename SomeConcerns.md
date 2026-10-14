# 一些考虑

- [x] skill
基于已成功上架的Apps，构建一个上架skill

- [ ] ShinyApps
Readme和wiki中，添加信息：如果你想上架自己的app，或者想上架别人的app，可以联系我，我可以帮助上架

- [ ] shinyelectron
App Downloads 排行榜，或者launcher页面，每个app显示下载次数和github star counts

- [ ] ShinyApps and shinyelectron
收录一些不方便上架的、或者无法上架的，但是已经在其它地方上架的Apps，列出app的信息，及访问使用链接，作为一个数据库来使用。可能需要要定制shinyelectron

- [ ] ShinyApps and skills
-调研 CRAN/BiocManager 中有哪些值得上架的Shiny app R包，并且可行性要足够。

- [ ] skill
我在ShinyApps中测试ClusterProfShinyORA 时，发现app无法正常启动成功，请参考更新后的onboarding skill更新一下fentouxungui/ClusterProfShinyORA里的build app bundle workflow，加入冒烟测试job，然后重新release一下，测试一下新加入的冒烟测试工作能否正常运行，并且发现问题，最后如果发现了问题，请协助解决问题。

- [x] shinyelectron
我是用最新的fentouxungui/shinyelectron multi-app-store 分支重新release了 ShinyApps v0.1.2版本，然后在本地的ShinyApps v0.1.1软件中更新ShinyApps应用，发现点击restart后，没有弹出任何安装的界面，但是安装过程悄无声息的就安装完了，请检查一下是怎么回事，是不是先前的app下载安装代码修改也影响了ShinyApps应用的安装？

- [x] shinyelectron
在ShinyApps中的Mange applications中点击安装某个app，然后再去点击别的app的‘Run’或‘Install’，或其他按钮，没有任何反应,这个现象是符合设计的吗？如果就是符合设计逻辑的话，有没有必要加一个提示，说正在下载安装软件，请等待完成后再运行其他任务。

- [ ] skill
如何给在ShinyApps上架的App添加一个收录的标志，可以是徽章吗，比如在其github介绍页面，添加一个badge，可以显示status（ShinyApps Catalog里的）和“ShinyApps Store”字符，然后点击后可以链接到shinyapp软件的下载页面，这样可以吗，你有什么更好的建议？先讨论一下。
在skill中作为一个option选项？如果作者愿意，可以复制一行代码到app的readme文件中，就可以显示该徽章了，
话说，如何制作为ShinyApps制作一个好看的徽章。然后如果走徽章这条路，可以拿我github账号中复刻的各个仓库为例，通过修改Readme文件，加入徽章，测试效果。

- [x] shinyelectron
可不可以加一个手动下载功能，就是自行从某个app的release页面下载bundle页面到本地，然后，让ShinyApps安装本地的软件，安装需要检查是否符合条件，比如R版本，并且允许安装非ShinyApps上架的App。


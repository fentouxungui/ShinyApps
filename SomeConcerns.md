# 一些考虑

- [x] skill

  基于已成功上架的Apps，构建一个上架skill

- [x] ShinyApps
  Readme和wiki中，添加信息：如果你想上架自己的app，或者想上架别人的app，如果不想自己折腾上架流程，也可以联系我，我可以帮助上架你的或你感兴趣的app

- [ ] shinyelectron
  只在All页面显示每个app的下载次数和 github star counts。非ShinyApps官方收录的app，如果没有github和download url，就不显示。

- [ ] ShinyApps and shinyelectron
  收录一些ShinyApps不方便上架的、或者无法上架的，但是已经在其它地方上架的Apps，列出这些app的信息，及使用链接，作为一个数据库集成到ShinyApps中，供大家检索和通过网页链接来访问。可能需要要定制shinyelectron

- [ ] ShinyApps and skills - **放弃**
  调研 CRAN/BiocManager 中有哪些值得上架的Shiny app R包，并且可行性要足够。

- [ ] ShinyApps and skills- **放弃**
  调研 CRAN/BiocManager 中有哪些包可以较容易的打包为Shiny App，可参考我将scConvert包装为scConvertShiny的过程。

- [ ] ShinyApps and skills- **放弃**

  调研已发表的文献，有哪些哪些值得上架的Shiny app R包（未被CRAN/BiocManager收录的），并且可行性要足够。

- [x] skill
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

- [ ] shinyelectron
  目前ShinyApps只允许使用一个Catalog URL，后续考虑允许使用多个，对于Catalog里面重复的app id进行处理，按照Catalog URL的优先顺序，仅保留优先出现的app。
  
- [ ] shinyelectron and shinyapps
  如果原app提供网页版应用，则在catlog中收录这个url，可以是多个，然后再...中显示official online app，点击链接到网页上。

// 清洗CSMAR上市公司数据库，视频链接：https://www.bilibili.com/video/BV1554y1F7ZZ/?spm_id_from=333.999.0.0&vd_source=98039f13de3b2f3189b572cfb9e18464
cd "/Users/xrb/Desktop/Stata学习/Dofiles of stata/清洗合并CSMAR数据" //设置工作目录

global raw "/Users/xrb/Desktop/Stata学习/Dofiles of stata/清洗合并CSMAR数据/raw"
global clean "/Users/xrb/Desktop/Stata学习/Dofiles of stata/清洗合并CSMAR数据/clean"
// 定义文件目录全局暂元，方便后续操作


//1.导入并初步处理数据
//资产负债表
import excel "$raw/资产负债表172234437(仅供北京交通大学使用)/FS_Combas.xlsx",firstrow clear //第一行作为变量名

labone, nrow(1 2) concat("_") //使用前两行生成标签，用_连接

drop in 1/2 //删除前两行

destring _all,replace //把所有字符型变量转为数值型

gen year = substr(Accper,1,4) //生成年份变量并转为数值型
destring year,replace
// gen year = real(substr(Accper,1,4)) ,replace //一行代码实现

drop ShortName Accper Typrep //删除不要的变量

order Stkcd year //把公司代码和年份两个变量排在前面

save "$clean/资产负债表.dta",replace //保存数据


//现金流量表,开始复用上面的代码 :)
import excel "$raw/现金流量表(直接法)172634910(仅供北京交通大学使用)/FS_Comscfd.xlsx",firstrow clear
labone, nrow(1 2) concat("_") 
drop in 1/2 
destring _all,replace 
gen year = substr(Accper,1,4) 
destring year,replace
// gen year = real(substr(Accper,1,4)) ,replace //一行代码实现
drop ShortName Accper Typrep
order Stkcd year
save "$clean/现金流量表.dta",replace 


//利润表
import excel "$raw/利润表172434978(仅供北京交通大学使用)/FS_Comins.xlsx",firstrow clear
labone, nrow(1 2) concat("_") 
drop in 1/2 
destring _all,replace 
gen year = substr(Accper,1,4) 
destring year,replace
// gen year = real(substr(Accper,1,4)) ,replace //一行代码实现
drop ShortName Accper Typrep
order Stkcd year
save "$clean/利润表.dta",replace 



//2.对接合并数据
use "$clean/资产负债表.dta",clear
merge 1:1 Stkcd year using "$clean/现金流量表.dta"
drop if _merge != 3 //删除未匹配样本
drop _merge //删除merge变量

merge 1:1 Stkcd year using "$clean/利润表.dta" //继续合并
drop if _merge != 3 //删除未匹配样本
drop _merge //删除merge变量

//生成杠杆率变量
gen lev = A002000000/A001000000 
//处理极端值
drop if lev > 1
//缩尾处理
winsor2 lev ,replace cuts(1 99) by(year)


save "$clean/财务数据清洗合并.dta",replace





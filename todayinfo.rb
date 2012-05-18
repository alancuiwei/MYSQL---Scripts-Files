#! /usr/share/ruby-rvm/bin/ruby
#encoding:utf-8 
require "open-uri"
require 'rubygems'  
require 'hpricot' 
require 'mysql'  


open("http://www.gwf.com.cn/cgi/index/First?function=ArticleList&pcatalog_no=Home_Page&menu_id=Trade_Tips"){|x|
aFile = File.new("todayinfo/2.txt","w")
while line = x.gets                          #打开网页，下载源码存到2.txt
         aFile.puts line.encode("utf-8"); 
 end 
 aFile.close 
}
f=open('todayinfo/2.txt')              #读网页源码，进行处理
line_array=f.readlines
s=line_array.length
i=0	   
while(i<s)                          #删除空行，将不包含"<"的行删除
 if(not line_array[i].include?("<"))
      u=i
      while(u<s)
	   line_array[u]=line_array[u+1] 
	   u += 1
	   end
  s -= 1
   end	
   i += 1 
end
i=0
while(i<s)                                         #找到最新链接那一行，提取网址
 if( line_array[i].include?('<td><a href="'))
     u=line_array[i].split('"')[1]
	break
   end	
   i += 1 
end  
 f='http://www.gwf.com.cn'+u
 open(f){|x|                                 #同Line  27 ,下载源码存到3.txt
aFile = File.new("todayinfo/3.txt","w")
while line = x.gets
         aFile.puts line.encode("utf-8")     
 end 
 aFile.close 
}

f=open('todayinfo/3.txt')                     #3.txt转成html文件
line_array=f.readlines
s=line_array.length
 fileHtml = File.new("todayinfo/test.html", "w+") 
i=0
 while(i<s) 
    fileHtml.puts line_array[i]
  i+=1
  end
fileHtml.close()
f.close

f=open('todayinfo/3.txt')                   
line_array=f.readlines
s=line_array.length
l=Array.new(s,0)  

i=0
while(i<s)                      
     l[i]=line_array[i]    	 
   i += 1 
end 
i=0
while(i<s)                                                   #取时间，Line 467 使用
     if(l[i].include?("<td")&&l[i].include?('<P>'))
	        time=l[i].gsub(/.*\(/,'')
	        time=time.gsub(/\).*/,'')
	   break
     end	 
   i += 1 
end 
file = File.new("todayinfo/newfile.xml", "w+")
i=0
while(i<s)                                            #提取包含数据的相关代码，存于newfile.xml
 if( l[i].include?('<P>'))
   file.puts l[i]   
  end	
   i += 1 
end 
file.close()

doc = Hpricot(open('todayinfo/newfile.xml'))           #解析xml
p=doc.search("p").inner_html
q=p.split("<br />")
i=0
while(q[i])             
       i += 1 
end 
 s=i
f=Array.new(s,0)
i=0
while(i<s )                                              #删除无关字符，保留合约名及比例
		   f[i]=q[i].gsub(/(2012[^>]+)/,' ')        		   
	       f[i]=f[i].gsub(/[^[a-z0-9A-Z%-]]/,' ')
	#	   f[i]=f[i].gsub(/\b \d{1,3} \b/,' ')
	       f[i]=f[i].gsub(/-/,' ')
	       f[i]=f[i].gsub(/\b[a-zA-Z]{4}\b/,'')
	       f[i]=f[i].gsub(/\b  *\b/,' ')
   i += 1
end 

i=0
g=f[0].to_s
while(i<s)                       #字符串连接
     i += 1 
	 g=g+' '+f[i].to_s
end 
g=g.split(" ")

i=0
while(g[i])  
     i += 1 
end 
s=i
i=0
while(i<s)                           #百分数化小数
      if(g[i].include?("%"))
	  g[i]=g[i].to_f/100
	  end
     i += 1 
end 
i=0
while(i<s)  
	  g[i]=g[i].to_s
     i += 1 
end 
                                    # pb1301          pb1301                               pb1301
i=0                                 # 1303    =>      pb1303           =>                  0.2             格式转换
while(i<s)                          # 1304            pb1304                               pb1303
    if(g[i]=~/\b\d{4}\b/) 	        # 0.2             0.2                                  0.2
           g[i]=g[i-1].gsub(/\d{4}/,'')+g[i]                                       #       pb1304
	end                                                                            #       0.2
  i+=1
end                         
 
i=0
while(i<s)             
    if(g[i]=='al') 	     
	     s += 1
		 t=s-1
		  while(i < t)		
	        g[t]=g[t-1] 
	        t -= 1	   
	      end
     g[i]='BaoZhengJin'
	 break
	end
  i+=1
end 
i=0
while(i<s)             
    if(g[i]=='al') 	     
	     s += 1
		 t=s-1
		  while(i < t)		
	        g[t]=g[t-1] 
	        t -= 1	   
	      end
     g[i]='ShangHai'
	 break
	end
  i+=1
end 
i=0
while(i<s)             
    if(g[i]=='a') 	     
	     s += 1
		 t=s-1
		  while(i < t)		
	        g[t]=g[t-1] 
	        t -= 1	   
	      end
     g[i]='DaLian'
	 break
	end
  i+=1
end  
i=0
while(i<s)             
    if(g[i]=='WT') 	     
	     s += 1
		 t=s-1
		  while(i < t)		
	        g[t]=g[t-1] 
	        t -= 1	   
	      end
     g[i]='ZhengZhou'
	 break
	end
  i+=1
end  
i=0
while(i<s)             
    if(g[i][0,2]=='IF') 	     
	     s += 1
		 t=s-1
		  while(i < t)		
	        g[t]=g[t-1] 
	        t -= 1	   
	      end
     g[i]='Zhongqi'
	 break
	end
  i+=1
end 
i=s
while(i>0)             
    if(g[i]=='al') 	     
	     s += 1
		 t=s-1
		  while(i < t)		
	        g[t]=g[t-1] 
	        t -= 1	   
	      end
     g[i]='ZhangDieFu'
	 break
	end
  i-=1
end  
i=s
while(i>0)             
    if(g[i]=='al') 	     
	     s += 1
		 t=s-1
		  while(i < t)		
	        g[t]=g[t-1] 
	        t -= 1	   
	      end
     g[i]='ShangHai'
	 break
	end
  i-=1
end 
i=s
while(i>0)             
    if(g[i]=='a') 	     
	     s += 1
		 t=s-1
		  while(i < t)		
	        g[t]=g[t-1] 
	        t -= 1	   
	      end
     g[i]='DaLian'
	 break
	end
  i-=1
end 
i=s
while(i>0)             
    if(g[i]=='WT') 	     
	     s += 1
		 t=s-1
		  while(i < t)		
	        g[t]=g[t-1] 
	        t -= 1	   
	      end
     g[i]='ZhengZhou'
	 break
	end
  i-=1
end 
i=s
while(i>0)                                 #格式转换
    if(g[i]=~/^[a-zA-Z]{1,2}\d{4}$/&&g[i-1]=~/^[a-zA-Z]{1,2}\d{4}$/)
	      s+=1
		  u=s-1
		  while(u>i)
             g[u]=g[u-1]
			 u-=1
	     end
		 g[i]=g[i+2]
    end	
    i -= 1 
end 
i=0
while(g[i]!='Zhongqi')      
	  i+=1
end
a=i
i=0
while(i<a)
    if(g[i]=~/\b[A-Z]{2}\d{4}\b/)
      g[i]=g[i][0,2]+g[i][3,3]
	end
   i+=1
end
fileHtml = File.new("todayinfo/5.txt", "w+")
i=0
  while(i<s) 
    fileHtml.puts g[i]
  i+=1
  end
fileHtml.close()

fo=open('todayinfo/5.txt') 
f=fo.readlines
i=0
while(f[i]) 
       f[i]=f[i].gsub(/\n/,'')   
       i += 1 
end 
s=i
go=open('../tongtianshun/app/assets/images/validcontracts.fl')
g=go.readlines  
i=0
while(g[i])             
       i += 1 
end 
t=i
i=0
while(i<t)  
    g[i]=g[i].gsub(/\n/,'')  
	u=g[i].gsub(/\d/,'').downcase                        #品种
     if(u=='al')                           #合约+品种
        g[i]=g[i]+','+'铝'
	 elsif(u=='zn')
	    g[i]=g[i]+','+'锌'
	 elsif(u=='cu')
	    g[i]=g[i]+','+'铜'
	 elsif(u=='pb')
	    g[i]=g[i]+','+'铅'
	 elsif(u=='au')
	    g[i]=g[i]+','+'黄金'
	 elsif(u=='ru')
	    g[i]=g[i]+','+'橡胶'
	 elsif(u=='fu')
	    g[i]=g[i]+','+'燃料油'
	 elsif(u=='rb')
	    g[i]=g[i]+','+'螺纹钢'
	 elsif(u=='wr')
	    g[i]=g[i]+','+'线材'
	 elsif(u=='a')
	    g[i]=g[i]+','+'黄大豆'
	 elsif(u=='b')
	    g[i]=g[i]+','+'黄豆二'
	 elsif(u=='c')
	    g[i]=g[i]+','+'玉米'
	 elsif(u=='m')
	    g[i]=g[i]+','+'豆粕'
	 elsif(u=='y')
	    g[i]=g[i]+','+'豆油'
	 elsif(u=='l')
	    g[i]=g[i]+','+'聚乙烯'
	 elsif(u=='p')
	    g[i]=g[i]+','+'棕榈油'
	 elsif(u=='v')
	    g[i]=g[i]+','+'聚氯乙烯'
	 elsif(u=='j')
	    g[i]=g[i]+','+'焦炭'
	 elsif(u=='wt')
	    g[i]=g[i]+','+'硬麦'	
	 elsif(u=='ws')
	    g[i]=g[i]+','+'强麦'
	 elsif(u=='er')
	    g[i]=g[i]+','+'早籼稻'
	 elsif(u=='cf')
	    g[i]=g[i]+','+'棉花'
	 elsif(u=='sr')
	    g[i]=g[i]+','+'白糖'
	 elsif(u=='ta')
	    g[i]=g[i]+','+'精对苯二甲酸'
	 elsif(u=='ro')
	    g[i]=g[i]+','+'菜籽油'	
	 elsif(u=='me')
	    g[i]=g[i]+','+'甲醇'
	 elsif(u=='pm')
	    g[i]=g[i]+','+'普麦'	
	 elsif(u=='if')
	    g[i]=g[i]+','+'股指'
	 elsif(u=='ag')
	    g[i]=g[i]+','+'白银'			
     end
	j=0
    while(j<s)                                  #合约+品种+交易所
	v=0
		if(u=='if')
		g[i]=g[i]+',中期'
		v=1

		break
		end
	if(v==0)
	     if(f[j].downcase==u.downcase)
		 v=j
		 while(not f[v][0,3]=~/\b[a-zA-Z]{3}\b/)
		    v-=1
		 end		 
	     if(f[v]=='ShangHai')
		 g[i]=g[i]+','+'上海'
		 elsif(f[v]=='DaLian')
		 g[i]=g[i]+','+'大连'
		 else
		 g[i]=g[i]+','+'郑州'
		 end
		 break
	     end
    end
        j += 1 
    end  
    
	w=0
    while(f[w][0,10]!='ZhangDieFu')             
         w+=1
    end 
	a=0
       if(u=='if')
	   a=1
	   end
	if(a==0)   
      v=0
	    j=0
        while(j<w)                             #合约+品种+交易所+保证金比例
           if(g[i][0,6]==f[j]||g[i][0,5]==f[j])
		   g[i]=g[i].gsub(/\n/,'')+','+f[j+1]
		   v=1
		   end				
           j += 1 	  
        end
	  if(v==0)
	    j=0
	    while(j<w)
	        if(f[j].downcase==u.downcase)
	        break
	        end
	        j+=1
	    end
        g[i]=g[i].gsub(/\n/,'')+','+f[j+1]
	  end
	
	  v=0
	  j=w
      while(j<s)                                         #合约+品种+交易所+保证金比例+涨跌停比例
        if(g[i][0,6]==f[j]||g[i][0,5]==f[j])
		g[i]=g[i].gsub(/\n/,'')+','+f[j+1]
		v=1
		end				
        j += 1 	  
      end
	  if(v==0)
	  j=w
	   while(j<s)
	    if(f[j].downcase==u.downcase)
	    break
	    end
	    j+=1
	    end
        g[i]=g[i].gsub(/\n/,'')+','+f[j+1]
	   end
    end
	if(u=='if')
	  a=0
	  j=w
      while(j<s)                                        
        if(g[i][0,6]==f[j])
		g[i]=g[i].gsub(/\n/,'')+','+f[j+1]+',0'
		a=1
		end				
        j += 1 	
	  end
      if(a==0)
		g[i]=g[i].gsub(/\n/,'')+',0,0'
	  end
	end
	i += 1 
end 	  

fileHtml = File.new("todayinfo/todayinfo.csv", "w+")
i=0
  while(i<t) 
    fileHtml.puts g[i]
  i+=1
  end
fileHtml.close() 

f=open('todayinfo/todayinfo.csv')                   #生成todayinfo.html
g=f.readlines  
i=0
while(g[i])             
       i += 1 
end 
s=i
i=0
while(i<s) 
       g[i]='<tr><td>'+g[i].gsub(/,/,'</td><td>')+'</td></tr>'           
       i += 1 
end   
s=s+9 
g[s-9]='</table>'
i=s-1
while(i>0) 
    g[i] =g[i-8]	
       i -= 1 
end

g[0]='<style>'
g[1]='.rttableformat {margin-top:5px;padding:5px;border-collapse:collapse;border-spacing:0;}'
g[2]='.rttableformat th{padding:5px; font: normal 12px Hiragino Sans GB W3, Helvetica, sans-serif;border:1px  solid #c9e4f5; text-align:center; }'
g[3]='.rttableformat td{padding:5px; font: normal 12px Hiragino Sans GB W3, Helvetica, sans-serif;border:1px  solid #c9e4f5; text-align:center;}'
g[4]='</style>'
g[5]='<tr>'+time+'</tr>'
g[6]='<table class="rttableformat">'
g[7]='<tr><th>合约</th><th>品种</th><th>期货交易所</th><th>保证金比例</th><th>涨跌停比例</th></tr>'

fileHtml = File.new("../tongtianshun/app/assets/images/todayinfo.html", "w+")
i=0
  while(i<s) 
    fileHtml.puts g[i]
  i+=1
  end
fileHtml.close() 

f=open('todayinfo/todayinfo.csv')                   #csv写入Mysql
g=f.readlines  
i=0
while(g[i])             
       i += 1 
end 
s=i

begin
dbh = Mysql.real_connect('localhost', 'root', '123456', 'webfuturetest_101',3306) 
dbh.query("set names utf8")
#dbh.query("drop table if exists todayinfo_t") #ruby执行语句
#dbh.query("create table todayinfo_t(contractid varchar(20),commodityid varchar(40),exchname varchar(20),margin float,updownlimit float)")
dbh.query("delete from todayinfo_t")
i=0
while(i<s) 
        a=g[i].split(',')
        t="insert into todayinfo_t values('"+a[0]+"','"+a[1]+"','"+a[2]+"',"+a[3]+","+a[4]+");"
        # puts t
        dbh.query(t)  
      i += 1 
end 

rescue Mysql::Error=>e           #Mysql执行错误时给出错误类型
puts "Error code:#{e.errno}"
puts "Error message:#{e.error}"
puts "Error SQLSTATE:#{e.sqlstate}" if e.respond_to?("sqlstate")
ensure
dbh.close if dbh
end




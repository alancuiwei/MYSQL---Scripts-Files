#encoding: utf-8
require "open-uri"

#当日股票数据

now_time=Time.new
c=now_time.year.to_i
a=now_time.month.to_i
b=now_time.day.to_i
a=a-1
d=b-1
h=open('Stocks/stock/file2.txt')                   #获取当日股票数据
line_array=h.readlines
ss=line_array.length

j=0	   
while(j<ss)                       
   begin
   puts g=line_array[j].gsub(/\n/,'')
   #g='600000.SS'

   source='http://table.finance.yahoo.com/table.csv?s='+g+'&a='+a.to_s+'&b='+d.to_s+'&c='+c.to_s+'&d='+a.to_s+'&e='+b.to_s+'&f='+c.to_s+'&ignore=.csv'
   file='Stocks/stock/'+g+'.csv'
   aFile = File.new(file,"w") 
   open(source){|x|
     while line = x.gets                      
         aFile.puts line     
     end 
         aFile.close 
    }
   rescue
   j=j+1
   next
   end
   j=j+1
end

#=begin
h=open('Stocks/stock/file2.txt')            #将今日股票数据插入对应CSV文件
line_array=h.readlines
ss=line_array.length

j=0	   
while(j<ss)                       
   puts g=line_array[j].gsub(/\n/,'')
   #g='600000.SS'
   gg='Stocks/stock/'+g+'.csv'
   h=open(gg)            
   line=h.readlines
   s=line.length
   ggg='Stocks/'+g+'.csv'
   logfile=open(ggg,'a')
 #  i=s-1
 #  while(i>0)
 #  puts line[i]
   logfile.puts line[1]
 #  i=i-1
 #  end
   logfile.close
   j=j+1
end
#=end
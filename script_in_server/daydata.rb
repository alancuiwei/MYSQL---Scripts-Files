#encoding:utf-8
require 'rubygems'
require "mysql"
require "open-uri"

dbh = Mysql.real_connect('localhost', 'root', '123456', 'futuretest',3306) 
sth=dbh.prepare("select * from marketdaydata_t ") 
sth.execute 
file = File.new("daydata/data.txt", "w+")
while row=sth.fetch do 
   file.puts row 
end 
file.close()

h=open('daydata/data.txt')                
line=h.readlines
ss=line.length
j=0	  
while(j<ss)                       
   g=line[j].gsub(/\n/,'')
   if(g=~/^[a-zA-Z]{1,2}\d{3,4}$/)          
       gg='daydata/'+g.gsub(/\d/,'')+'/'+g+'.csv'
	   if(not File.exist?(gg))
       aFile = File.new(gg,"w") 
       aFile.puts 'Contractid,Date,Open,High,Low,Close,Volume,Openinterest'
       aFile.close 	   
       end
	   logfile=open(gg,'a')                    
       logfile.puts g+','+line[j+1].split(' ')[0]+','+line[j+2].gsub(/\n/,'')+','+line[j+3].gsub(/\n/,'')+','+
	                      line[j+4].gsub(/\n/,'')+','+line[j+5].gsub(/\n/,'')+','+line[j+6].gsub(/\n/,'')+','+line[j+7].gsub(/\n/,'')
       logfile.close
   end
   j=j+1
end







=begin
i=0
for(i<s)
ll=l[i]+'.zip'
def compress   
  Zip::ZipFile.open ll, Zip::ZipFile::CREATE do |zip|   
    add_file_to_zip('../tongtianshun/app/assets/historydatadownload/daydata', zip)   
  end  
end
i=i+1
end

def add_file_to_zip(file_path, zip)   
  if File.directory?(file_path)   
    Dir.foreach(file_path) do |sub_file_name|   
      add_file_to_zip("#{file_path}/#{sub_file_name}", zip) unless sub_file_name == '.' or sub_file_name == '..'  
    end  
  else  
    zip.add(file_path, file_path)   
  end  
end
=end



=begin
#encoding: utf-8
require "open-uri"
#创建所有csv文件
h=open('a.txt')                
line_array=h.readlines
ss=line_array.length
j=0	   
while(j<ss)                       
   puts g=line_array[j].gsub(/\n/,'')
   file='daydata/'+g+'.csv'
   aFile = File.new(file,"w") 
   aFile.puts 'Contractid,Date,Open,High,Low,Close,Volume,Openinterest'
   aFile.close 
   j=j+1
end
#插入数据
h=open('marketdaydata_t.txt')                
line_array=h.readlines
ss=line_array.length
j=0	   
while(j<ss)           
   puts j            
   g=line_array[j].split(',')[0]
   gg='daydata/'+g+'.csv'

   logfile=open(gg,'a')                    
       logfile.puts line_array[j].split(',')[0]+','+line_array[j].split(',')[1]+','+line_array[j].split(',')[2]+','+line_array[j].split(',')[3]+','+
	                line_array[j].split(',')[4]+','+line_array[j].split(',')[5]+','+line_array[j].split(',')[6]+','+line_array[j].split(',')[7]
   logfile.close

   j=j+1
end
=end



=begin
#C:\Documents and Settings\All Users\Application Data\MySQL\MySQL Server 5.6\data\futuretest
#txt
INTO OUTFILE 'a.txt'
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n';
#csv
SELECT * FROM mytable  
INTO OUTFILE 'mytable.csv' 
FIELDS TERMINATED BY ','  
OPTIONALLY ENCLOSED BY '"'  
LINES TERMINATED BY '\n'； 
=end

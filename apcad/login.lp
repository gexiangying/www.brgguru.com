<!DOCTYPE html>
<% local apcad = _G.require("apcad.apcad") %>
<html>
	<head>
		<title>用户管理</title>
		<%=apcad.head %>
	</head>
	<body>
		 <%
			 local url = _G.require("lpp.url")
		 %>
		<div data-role="page" id="main">
			<%=apcad.header(sessionid) %>
				<%
					local logined = true 
					local M ={}
			    local ct
          local softs
												
          if not user and not psw and sessionid then
            local session = apcad.session_db(sessionid)
            user = session["user"]
            psw = session["psw"]
					end
												
			    if user and psw then
          if sessionid then 
												apcad.session_save(sessionid,"user",user)
												apcad.session_save(sessionid,"psw",psw)
					end
 				  ct = _G.socket.connect(apcad.addr,apcad.port)
  				local str="login\r\n" ..user .. "\r\n" .. psw .. "\r\n"
					apcad.send_str(ct,str)
					local answer = apcad.recv_str(ct)
					if (answer == "login\r\n-1\r\n") then
						logined = false 
					else

						local cmd = "get_softs\r\n"	
						apcad.send_str(ct,cmd)
						apcad.farse_recv(ct,M)
						softs = M.softs

						cmd = "get_balance\r\n" .. user .. "\r\n" .. psw .. "\r\n"
						apcad.send_str(ct,cmd)
						apcad.farse_recv(ct,M) 

						cmd = "get_trades\r\n" .. user .. "\r\n" .. psw .. "\r\n"
						apcad.send_str(ct,cmd)
						apcad.farse_recv(ct,M)
					end
					ct:close()
          else
						logined = false
					end
					%>
					<% if logined then %>
					  <div data-role="content">
						<ul data-role="listview" data-insert="true" data-divider-theme="a">
						<% if M.balance then %>
							<li data-role="list-divider">用户信息</li>
								<li>用户名:<%=user %></li>
								<li>账户余额:<%=M.balance %></li>
						<% end %>
							<li data-role="list-divider">软件列表</li>
							<%
					 local keys = {}
					 for k,v in _G.pairs(softs) do
					   keys[#keys+1] = k
					 end
					 _G.table.sort(keys)
					 %>
						<% for i,k in _G.ipairs(keys) do %>
							<%
					      local v = softs[k]
					      local m = {}
					      m.user = user
					      m.pass = _G.luaext.md5(psw)
					      m.soft = k
					      m.price = softs[k].price
					      m.sessionid = sessionid
								local ref_str = "soft.lp?" .. url.encodetable(m)
								--local soft_dir = _G.string.sub(k,1,2)
							%>
							<li>
							<a href="<%=ref_str %>"><%= k %></a>
							</li>
					  <% end %>
	
					 <li data-role="list-divider">交易记录</li>


						<li>
					 <table width="100%" class="ui-responsive table-stripe" >
						 <thead>
							 <tr>
								 <th>软件名称</th>
								 <th>购买时间</th>
								 <th>到期日期</th>
							 </tr>
						 </thead>
						 <tbody>
					<% 
					local t={}
					local function cmp(a,b)
						return a[2]	> b[2]				
					end

					for k,v in _G.pairs(M.trades) do 
						 t[#t+1] = {k,v.date}
					end							
          _G.table.sort(t,cmp)
          for i,m in _G.ipairs(t) do
					local id = m[1] 
					local v = M.trades[id]
					local softname = v.softname
					local startdate = v.date
					local enddate = v.expire or (v.date + v.months * 60*60*24*30)
					local start_str = _G.os.date("%x",startdate) 
					local end_str = _G.os.date("%x",enddate)
					%>
						<tr>
							<td><%=softname %></td>
							<td><%=start_str %></td>
							<td><%=end_str %></td>
						</tr>
						<% end %>
						 </tbody>
					 </table>
						</li>
					<% else %>
					<h1>login error!</h1>
					<% end %>
				 </ul>
			</div>
			<%=apcad.footer %>
		</div>
		</body>
</html>

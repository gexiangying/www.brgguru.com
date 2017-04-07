<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<% local url = _G.require("lpp.url") %>
<html> 
	<head> 
		<title>全场计算</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page" > 
      <%=tour.header %>
			<div data-role="content">
			<% if not tour_no then %>
				<h2>比赛列表:</h2>
			<ol data-role="listview">
			<% local tour_list = tour.load_tour_list()
				for k,v in _G.pairs(tour_list) do 
			  if v.tour_type and v.tour_type == "team" then
				local linkname = "score.lp?tour_no=" .. url.escape(k) %>
				<li> <a href="<%=linkname %>"><%=k %></a></li>
				<% end %>
				<% end %>
			</ol>
			<% elseif not round then %>
			<h2>轮次:</h2>
				<ol data-role="listview">
					<% local tour_list = tour.load_tour_list() 
				local t = tour_list[tour_no] or {} 
				for i=1,t.rounds do
				local linkname = "score.lp?tour_no=" .. url.escape(tour_no) .. "&round=" .. i%>
				<li> <a href="<%=linkname %>">第<%=i %>轮</a></li>
				<% end %>
				</ol>
			<% elseif not desk1 then %>
			<h2>开室:</h2>
				<ol data-role="listview">
					<% local tour_list = tour.load_tour_list() 
				local t = tour_list[tour_no] or {} 
				for i=1,t.desks do
				local linkname = "score.lp?tour_no=" .. url.escape(tour_no) .. "&round=" .. round .. "&desk1=" .. i%>
				<li> <a href="<%=linkname %>">第<%=i %>桌</a></li>
				<% end %>
				</ol>
			<% elseif not desk2 then %>
			<h2>闭室:</h2>
				<ol data-role="listview">
					<% local tour_list = tour.load_tour_list() 
				local t = tour_list[tour_no] or {} 
				for i=1,t.desks do
				local linkname = "score.lp?tour_no=" .. url.escape(tour_no) .. "&round=" .. round .. "&desk1=" .. desk1 .. "&desk2=" .. i%>
				<li> <a href="<%=linkname %>">第<%=i %>桌</a></li>
				<% end %>
				</ol>
	    <% end %>
	    </div>		
			<% if tour_no and round and desk1 and desk2 then %>
			<%
      local db1 = tour.load_db(tour_no,round,desk1)
      local db2 = tour.load_db(tour_no,round,desk2)
      local userlist = tour.load_user_list()
			local open = tour.get_desk_sets(desk1,tour_no,round)
			local close = tour.get_desk_sets(desk2,tour_no,round)
      local index = {}
			tour.fill_index(index,open,1) 
			tour.fill_index(index,close,2) 
		  tour.cal_imp(index)	
			%> 
			<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
					<thead>
						<tr>
							<th colspan="2">开室</th>
							<th colspan="2">闭室</th>
						</tr>
						<tr>
							<th >南北</th>
							<th >东西</th>
							<th >南北</th>
							<th >东西</th>
						</tr>
					</thead>

				<% if db1.N_no and db1.S_no and db1.E_no and db1.W_no and db2.N_no and db2.S_no and db2.E_no and db2.W_no then %>
					<tr>
							<td align="center"><%=userlist[db1.N_no] %> </td>
							<td align="center"><%=userlist[db1.E_no] %> </td>
							<td align="center"><%=userlist[db2.N_no] %> </td>
							<td align="center"><%=userlist[db2.E_no] %> </td>
					</tr>
					<tr>
							<td align="center"><%=userlist[db1.S_no]%></td>
							<td align="center"><%=userlist[db1.W_no]%></td>
							<td align="center"><%=userlist[db2.S_no]%></td>
							<td align="center"><%=userlist[db2.W_no]%></td>
					</tr>

					<% end %>
			</table>
			</div>
			<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
				<thead>
						<tr>
							<th></th>
							<th colspan="2">定约</th>
							<th colspan="2">得分</th>
							<th colspan="2">IMP</th>
						</tr>
						<tr>
							<th align="left">副序</th>
							<th >开室</th>
							<th >闭室</th>
							<th >开室</th>
							<th >闭室</th>
							<th ><%=desk1 %></th>
							<th ><%=desk2 %></th>
						</tr>
				</thead>
					<% local ns1,ns2 = tour.total_imp(index) 
					local keys = {}
          for k,v in _G.pairs(index) do 
              keys[#keys+1] = k												
					end
					_G.table.sort(keys)
					 %>
					<% for i,k in _G.ipairs(keys) do %>
					<% local v = index[k] %>
          <tr>
						<td><%=k %></td>
						<td><% if v[1] and v[1].str then %><%=v[1].str %><% end %></td>
						<td><% if v[2] and v[2].str then %><%=v[2].str %><% end %></td>
						<td><% if v[1] and v[1].score then %><%=v[1].score%><% end %></td>
						<td><% if v[2] and v[2].score then %><%=v[2].score%><% end %></td>
						<td><% if v[1] and v[1].imp then %><%=v[1].imp %><% end %></td>
						<td><% if v[2] and v[2].imp then %><%=v[2].imp %><% end %></td>
					</tr>
					<% end %>
					<tr>
						<td>总计</td>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td><%=ns1 %></td>
						<td><%=ns2 %></td>
					</tr>
					<tr>
						<td>VP</td>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td><%=tour.vp(#keys,ns1-ns2) %></td>
						<td><%=tour.vp(#keys,ns2-ns1) %></td>
					</tr>
				</table>
			</div>
		<% end %>
			<%=tour.footer %>
			</div>
	</body>
</html>		

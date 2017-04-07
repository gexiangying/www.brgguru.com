<!DOCTYPE html> 
<% 
 local tour = _G.require("brg.tour") 
 local luabridge = _G.require("brg.luabridge")
 local sets,db = tour.load_txs_sets("912")
 tour.txs_cal(sets)
 local NS,EW = tour.txs_sum(sets,db.desks)
 %>
<head> 
		<title>通讯赛成绩</title> 
		<%=tour.head %>
</head> 
<body>
	<div data-role="page">
		<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
					<tr>
						<th>名次</th>
						<th>南北</th>
						<th>mp</th>
						<th>ximp</th>
						<th>副数</th>
					</tr>
			<% for i,v in _G.pairs(NS) do %>
			<% local mp = v.mp / v.boards
			mp = mp - mp%0.01 %>
			<tr>
				<td>第<%=i %>名</td>
				<td><%=v.no %></td>
				<td><%=mp %></td>
				<td><%=v.ximp %></td>
				<td><%=v.boards %></td>
			</tr>
			<% end %>
				</table>
	</div>
	<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
					<tr>
						<th>名次</th>
						<th>东西</th> 
						<th>mp</th>
					 	<th>ximp</th>
					 	<th>副数</th>
					</tr>
			<% for i,v in _G.pairs(EW) do %>
			<% local mp = v.mp / v.boards
			mp = mp - mp%0.01 %>
			<tr>
				<td>第<%=i %>名</td>
				<td><%=v.no %></td>
				<td><%=mp %></td>
				<td><%=v.ximp %></td>
				<td><%=v.boards %></td>
			</tr>
			<% end %>
				</table>
	</div>


	<div>
		<div data-role="content">
			<ul data-role="listview" data-insert="true" data-divider-theme="a">
		<% local data = luabridge.mk_sets(sets) %>
   <% for i,v in _G.ipairs(data) do %>
	 <li data-role="list-divider">第<%=i %>副</li>
	 <li>
		 <table width="100%" class="ui-responsive table-stripe" >
			 <tr>
				 <th>南北</th>
				 <th>东西</th>
				 <th>桌号</th>
				 <th>轮次</th>
				 <th>定约</th>
				 <th>得分</th>
				 <th>mp</th>
				 <th>ximp</th>
			 </tr>
			<% for k,u in _G.ipairs(v) do %>
			<tr>
				<td><%=u.NS %></td>
				<td><%=u.EW %></td>
				<td><%=u.table %></td>
				<td><%=u.round %></td>
				<td><%=u.constr %></td>
				<td><%=u.score %></td>
				<td><%=u.NS_mp %></td>
				<td><%=u.NS_ximp %></td>
			</tr>
			<% end %>
		 </table>
		</li>	
	 <% end %>
	</ul>
	</div>

	<%=tour.footer %>
	</div>
</body>
</html>


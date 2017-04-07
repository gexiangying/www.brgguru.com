<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>精英群排行榜</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
			<div data-role="content">
				<form action="list.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">

						<li data-role="fieldcontain">
							<label for="tourdate">比赛日期:</label>
							<% if tourdate then %>
							<input type="date" name="tourdate" id="tourdate" value="<%=tourdate %>">
							<% else %>
							<input type="date" name="tourdate" id="tourdate" >
							<% end %>
						</li>

						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>
			</div>
			<% local db = tour.load_master() %>
			<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
					<thead>
						<tr>
							<th >序号</th>
							<th >日期</th>
							<th >时段</th>
							<th >姓名</th>
							<th >imps</th>
						</tr>
					</thead>
					<tbody>
					</tbody>
					<% for k,v in _G.pairs(db) do %>
						<% if tourdate and k == tourdate then %>
						<% for k1,v1 in _G.pairs(v) do %>
						<% local keys = {} %>
						<% for k2,v2 in _G.pairs(v1) do %>
						<% local temp = {} %>
						<% temp.k = k2 %>
						<% temp.v = v2 %>
						<% keys[#keys+1] = temp %>
						<% end %>
						<% _G.table.sort(keys, function(a,b) return a.v > b.v end) %>
						<% local no = 0 %>
					  <% for i,v3 in _G.ipairs(keys) do %>	
						<% no = no + 1 %>
						<tr>
							<td><%=no %></td>
							<td><%=k %></td>
							<td><%=k1 %></td>
							<td><%=v3.k %></td>
							<td><%=v3.v %></td>
						</tr>
						<% end %>
						<% end %>
						<% end %>
						<% end %>

				</table>
			</div>
		</div>
	</body>
</html>	

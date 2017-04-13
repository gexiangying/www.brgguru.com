<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<% local url = _G.require("lpp.url") %>
<html> 
	<head> 
		<title>编辑成绩表</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
			<%=tour.header %>
			 <div data-role="content">
				<% if not tour_no then %>
				<form action="edit_total.lp" method="POST" autocomplete="off" data-ajax="false">
					<ul data-role="listview" data-insert="true">
						<li data-role="fieldcontain">
							<label for="tour_no">比赛名称</label>
							<input type="text" name="tour_no" id="tour_no">
						</li>
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>
				<% elseif not vp and round then %>
				<form action="edit_total.lp" method="POST" autocomplete="off" data-ajax="false">
					<ul data-role="listview" data-insert="true">
						<% if not name then %>
						<li data-role="fieldcontain">
							<label for="name">名称</label>
							<input type="text" name="name" id="name">
						</li>
						<% else %>
						<input type="hidden" name="name" value="<%=name %>" >
						<% end %>
						<li data-role="fieldcontain">
							<label for="vp">vp</label>
							<input type="text" name="vp" id="vp">
						</li>
						<input type="hidden" name="tour_no" value="<%=tour_no %>" >
						<input type="hidden" name="round" value="<%=round %>" >
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>
				<% elseif tour_no and name and round and vp then %>
				<% tour.add_total(tour_no,name,round,vp) %>
        <% end %>
			</div>
			<% if tour_no then %>
			<%
					local pls,rounds = tour.load_total(tour_no)																					 
																					 %>
      <div data-role="content">
			<table width="100%" data-role="table" class="ui-responsive table-stripe" >
					<thead>
						<tr>
							<th>名称</th>
							<th>名次</th>
							<th>总成绩</th>
							<% for i=1,rounds do %>
							<th >第<%=i %>轮</th>
							<% end %>
							<th>调整</th>
						</tr>
					</thead>
					<tbody>
          <% for i,v in _G.ipairs(pls) do %>
					<tr>
          <td><%=v.name %></td>
          <td>第<%=i %>名</td>
					<td><%=v.total %></td>
					<% for round=1,rounds do %>
					<% local linkref = "edit_total.lp?" .. "tour_no=" .. url.escape(tour_no) .. "&name=" .. url.escape(v.name) .. "&round=" .. round %>
					<td><a href="<%= linkref %>"><%=v.vp[round] or 0 %></a></td>
					<% end %>
					<% local linkref = "edit_total.lp?" .. "tour_no=" .. url.escape(tour_no) .. "&name=" .. url.escape(v.name) .. "&round=" .. rounds+1 %>
					<td><a href="<%= linkref %>"><%=v.vp[rounds+1] or 0 %></a></td>
					</tr>
          <% end %>
					<tr>
          <td></td>
          <td></td>
					<td></td>
					<% for round=1,rounds+1 do %>
					<% local linkref = "edit_total.lp?" .. "tour_no=" .. url.escape(tour_no) .. "&round=" .. round %>
					<td><a href="<%=linkref %>">0</a></td>
					<% end %>
					</tr>
					</tbody>
			</table>
			</div>
			<% end %>
			<%=tour.adminfooter %>
		</div>
	</body>
</html>


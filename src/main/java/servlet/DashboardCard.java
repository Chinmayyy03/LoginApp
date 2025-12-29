package servlet;

public class DashboardCard {
    private int srNumber;
    private String description;
    private String funcationName;
    private String paramitar;
    private String tableName;
    private double value;
    private String pageLink;

    public DashboardCard() {
    }

    public DashboardCard(int srNumber, String description, String funcationName, String paramitar, String tableName) {
        this.srNumber = srNumber;
        this.description = description;
        this.funcationName = funcationName;
        this.paramitar = paramitar;
        this.tableName = tableName;
    }

    public int getSrNumber() {
        return srNumber;
    }

    public void setSrNumber(int srNumber) {
        this.srNumber = srNumber;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getFuncationName() {
        return funcationName;
    }

    public void setFuncationName(String funcationName) {
        this.funcationName = funcationName;
    }

    public String getParamitar() {
        return paramitar;
    }

    public void setParamitar(String paramitar) {
        this.paramitar = paramitar;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public double getValue() {
        return value;
    }

    public void setValue(double value) {
        this.value = value;
    }

    public String getPageLink() {
        return pageLink;
    }

    public void setPageLink(String pageLink) {
        this.pageLink = pageLink;
    }
}
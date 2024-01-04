var ChangeTab = {
    // ... other functions ...

    goToHome: function () {
        $("#HeroDiv").show();
        $("#LifestyleDiv, #TechDiv, #BusinessDiv, #ServicessDiv, #PortofolioDiv, #NewsDiv").hide();
    },

    goToLifestyle: function () {
        $("#LifestyleDiv").show();
        $("#HeroDiv, #TechDiv, #BusinessDiv, #ServicessDiv, #PortofolioDiv, #NewsDiv").hide();
    },

    goToTech: function () {
        $("#TechDiv").show();
        $("#LifestyleDiv, #HeroDiv, #BusinessDiv, #ServicessDiv, #PortofolioDiv, #NewsDiv").hide();
    },

    goToBusiness: function () {
        $("#BusinessDiv").show();
        $("#TechDiv, #LifestyleDiv, #HeroDiv, #ServicessDiv, #PortofolioDiv, #NewsDiv").hide();
    },

    goToServices: function () {
        $("#ServicessDiv").show();
        $("#TechDiv, #LifestyleDiv, #HeroDiv, #BusinessDiv, #PortofolioDiv, #NewsDiv").hide();
    },

    goToPortofolio: function () {
        $("#PortofolioDiv").show();
        $("#TechDiv, #LifestyleDiv, #HeroDiv, #BusinessDiv, #ServicessDiv, #NewsDiv").hide();
    },

    goToNews: function () {
        $("#NewsDiv").show();
        $("#TechDiv, #LifestyleDiv, #HeroDiv, #BusinessDiv, #ServicessDiv, #PortofolioDiv").hide();
    }
};

const baseUrl = process.env.PA11Y_BASE_URL || "http://localhost:4173";

module.exports = {
    defaults: {
        standard: "WCAG2AA",
        timeout: 10000,
        wait: 500
    },
    urls: [
        `${baseUrl}/`,
        `${baseUrl}/common-ground/`,
        `${baseUrl}/neighbor-first/`,
        `${baseUrl}/bold-campaign/`,
        `${baseUrl}/refined/`
    ]
};

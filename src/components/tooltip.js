import tippy from 'tippy.js';

export const tooltip = (node, params = {}) => {

    const custom = params.content;
    const title = node.title;
    const label = node.getAttribute("aria-label");
    const content = custom || title || label;
  
    if (!label) node.setAttribute("aria-label", content);
  
    node.title = "";
  
    const tip = tippy(node, { content, ...params });
  
    return {
      // If the props change, let's update the Tippy instance:
    //   update: (newParams) => tip.setProps({ content, ...newParams }),
  
      // Clean up the Tippy instance on unmount:
    //   destroy: () => tip.destroy(),
    };
  };

  export default tooltip; 
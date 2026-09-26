declare const DOMPurify: any;
export function bio(html: string) {
  // ruleid: crivo.sec-016.dangerously-set-inner-html
  const raw = <div dangerouslySetInnerHTML={{ __html: html }} />;
  // ok: crivo.sec-016.dangerously-set-inner-html
  const clean = <div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(html) }} />;
  return [raw, clean];
}
